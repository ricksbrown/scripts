import time
import os
import json


# Get file age in seconds
def get_age(file_path):
	file_info = os.stat(file_path)
	result = (time.time() - file_info.st_mtime)
	return result


class Cache:
	cache_root = 'cache'

	def __init__(self, course_id, student_name=''):
		self.course_id = course_id

		if not os.path.exists(self.cache_root):
			os.mkdir(self.cache_root)
	
		if student_name:
			self.cache_root = os.path.join(self.cache_root, student_name)
			if not os.path.exists(self.cache_root):
				os.mkdir(self.cache_root)

	def get_cache_path(self):
		return self.cache_root
	

	def get_cache_path(self):
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

	def get(self, course_work_id, max_age=0):
		file_path = self.get_file_path(course_work_id)
		# print('Checking cache for ' + course_work_id)
		if os.path.exists(file_path):
			# print('Cache hit ' + course_work_id)
			if max_age:
				age = get_age(file_path)
				if age < max_age:
					# print('Cache still fresh for ' + course_work_id)
					with open(file_path) as f:
						data = json.load(f)
						return data
		return None

	def clear(self, course_work_id):
		file_path = self.get_file_path(course_work_id)
		if os.path.exists(file_path):
			os.remove(file_path)
