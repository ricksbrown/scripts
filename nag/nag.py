from __future__ import print_function
import datetime
import pickle
import os
import json
import pyttsx3
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# If modifying these scopes, delete the file token.pickle.
SCOPES = [
		'https://www.googleapis.com/auth/classroom.courses.readonly',
		'https://www.googleapis.com/auth/classroom.coursework.me.readonly']


def is_submitted_curry(due_date):
	now = datetime.datetime.now().astimezone()

	def is_submitted(submission):
		nonlocal now
		state = submission.get('state', '')
		if state != 'TURNED_IN':
			if due_date > now:
				return True
			elif state != 'RETURNED':
				return True
	return is_submitted


def some(a_list: list, f: callable):
	for item in a_list:
		if f(item):
			return True
	return False


def fromgdate(goog_date, goog_time):
	result = datetime.datetime(
		goog_date['year'], goog_date['month'], goog_date['day'],
		goog_time.get('hours', 23), goog_time.get('minutes', 59), goog_time.get('seconds', 59), 0,
		tzinfo=datetime.timezone.utc)  # google dates are UTC
	result = result.astimezone()  # converts it to local time
	return result


def nag():
	engine = pyttsx3.init()
	now = datetime.datetime.now().astimezone()
	msgs = []
	if datetime.time(20, 30) <= now.time() < datetime.time(23, 59):
		msgs.append('Hello children, go to bed')
	elif datetime.time(18, 55) <= now.time() < datetime.time(19, 55):
		msgs.append('Hello children, do your chores')
	else:
		classroom = Classroom()
		not_submitted = classroom.get_not_submitted()
		if len(not_submitted) > 0:
			msgs.append('Pending homework')
			for work in not_submitted:
				due_date = fromgdate(work['dueDate'], work['dueTime'])
				msgs.append(work['title'] + '" - ' + due_date.strftime('%B %d, %Y'))
		else:
			msgs.append('Yay, all homework complete')

	for msg in msgs:
		print(msg)
		engine.say(msg)
	engine.runAndWait()


class Classroom:

	def __init__(self):
		# The file token.pickle stores the user's access and refresh tokens, and is
		# created automatically when the authorization flow completes for the first
		# time.
		if os.path.exists('token.pickle'):
			with open('token.pickle', 'rb') as token:
				credentials = pickle.load(token)
		# If there are no (valid) credentials available, let the user log in.
		if not credentials or not credentials.valid:
			if credentials and credentials.expired and credentials.refresh_token:
				credentials.refresh(Request())
			else:
				flow = InstalledAppFlow.from_client_secrets_file(
					'credentials.json', SCOPES)
				credentials = flow.run_local_server(port=0)
			# Save the credentials for the next run
			with open('token.pickle', 'wb') as token:
				pickle.dump(credentials, token)

		self.service = build('classroom', 'v1', credentials=credentials)

	def get_course_list(self):
		# Returns a list of active courses for the current student
		results = self.service.courses().list(courseStates='ACTIVE', studentId='me').execute()
		courses = results.get('courses', [])
		if 'nextPageToken' in results:
			print('Has more pages ' + results['nextPageToken'])
		return courses

	def get_course_work(self, course_id):
		# Returns a list of coursework that has a due date
		course_cache = Cache(course_id)
		results = course_cache.get(course_id)
		if results is None:
			results = self.service.courses().courseWork().list(courseId=course_id).execute()
			course_cache.put(course_id, results)
		course_work = results.get('courseWork', [])
		result = filter(lambda elem: 'dueDate' in elem, course_work)
		return result

	def get_submissions(self, course_id, course_work_id):
		course_cache = Cache(course_id)
		results = course_cache.get(course_work_id)
		if results is None:
			results = self.service.courses().courseWork().studentSubmissions().list(
				userId='me',
				courseId=course_id,
				courseWorkId=course_work_id).execute()
			course_cache.put(course_work_id, results)
		student_submissions = results.get('studentSubmissions', [])
		return student_submissions

	def get_not_submitted(self):
		result = []
		courses = self.get_course_list()
		for course in courses:
			# print('Checking class "%s"' % (course['name']))
			assignments = self.get_course_work(course['id'])
			if assignments:
				for assignment in assignments:
					due_date = fromgdate(assignment['dueDate'], assignment['dueTime'])
					submissions = self.get_submissions(assignment['courseId'], assignment['id'])
					if len(submissions) < 1 or some(submissions, is_submitted_curry(due_date)):
						result.append(assignment)
						self.uncache(assignment)  # these must not be cached otherwise the state will never change
		return result

	@staticmethod
	def uncache(assignment):
		course_cache = Cache(assignment['courseId'])
		course_cache.clear(assignment['id'])


class Cache:
	cache_root = 'cache'

	def __init__(self, course_id):
		self.course_id = course_id

	def get_cache_path(self):
		if not os.path.exists(self.cache_root):
			os.mkdir(self.cache_root)
		return os.path.join(self.cache_root, self.course_id)

	def get_file_path(self, course_work_id):
		cache_path = self.get_cache_path()
		file_path = os.path.join(cache_path, course_work_id + '.json')
		return file_path

	def put(self, course_work_id, obj):
		cache_path = self.get_cache_path()
		if not os.path.exists(cache_path):
			os.mkdir(cache_path)

		file_path = self.get_file_path(course_work_id)
		with open(file_path, 'w', encoding='utf-8') as f:
			json.dump(obj, f, ensure_ascii=False, indent=4)

	def get(self, course_work_id):
		file_path = self.get_file_path(course_work_id)
		if os.path.exists(file_path):
			# print('Cache hit ' + filePath)
			with open(file_path) as f:
				data = json.load(f)
				return data
		return None

	def clear(self, course_work_id):
		file_path = self.get_file_path(course_work_id)
		if os.path.exists(file_path):
			os.remove(file_path)


def main():
	nag()


if __name__ == '__main__':
	main()
