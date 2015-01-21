
# what is my objective here?
# 	given any tag:
#		-be able to add/delete it's fields
#		-be able to instantiate it and set it's field values
#			-includes all parent fields
#	dynamically define a new tag
#		-set its parent tag(s)
#		-add/delete fields
#
# so basically what's hard is figuring out what to do about
# the fact that we have to store both what type each field
# is and the actual value of the field when we instantiate
# a tags

# import uuid

class Typ:

	# ================================================================
	# Built-ins
	# ================================================================
	# TODO maybe add hidden fields
		# or maybe just
	def __init__(self, name, parents=None, fields=None, default=None):
		# sanity check args
		assert isinstance(name, str)
		if parents:
			assert all([isinstance(p, Typ) for p in parents])

		self.name = name
		self.default = default
		# self.children = children	# not strictly necessary, but helpful
		self._parents = parents
		# self._id = uuid.uuid4()

		# this avoids an insanely subtle error wherein everything gets
		# the same dict object passed in if we use {} as the default, and
		# thus modifications to one type's fields affect every type
		if fields:
			self._fields = fields
		else:
			self._fields = {}

	# we don't need a unique id since the default implementations
	# that just compare pointers will do the same thing...(well,
	# unless maybe we're serializing things and, say, comparing
	# a serialized and deserialized version, but not gonna worry
	# about that at the moment)
	# def __eq__(self, other):
	# 	if not isinstance(other, Typ):
	# 		return False
	# 	return self.__hash__() == other.__hash__()

	# def __ne__(self, other):
	# 	return not self.__eq__(other)

	# def __hash__(self):
	# 	return self._id

	def __repr__(self):
		s = self.fullName()
		# s = self.name
		# if self._parents:
		# 	names = ', '.join([p.name for p in self._parents])
		# 	s += ' (' + str(names) + ')'  # + '\n'
		if self.allFields():
			s += ": " + str(self.allFields().keys())  # + '(%d)' % (self._id)
		return s

	# ================================================================
	# Public funcs
	# ================================================================
	def fullName(self):
		if not self._parents:
			return self.name

		parentNames = map(lambda p: p.fullName(), self._parents)
		parentNames = sorted(parentNames)
		parentStr = ', '.join(parentNames)
		if len(parentNames) > 1:
			return "{%s}.%s" % (parentStr, self.name)
		return "%s.%s" % (parentStr, self.name)

	def defaultValue(self):
		fields = self.allFields()
		if fields:
			vals = [(name, typ.defaultValue()) for name, typ in fields.items()]
			return dict(vals)
		return self.default

	def allFields(self):
		fields = {}
		if self._parents:
			for p in self._parents:
				fields.update(p.allFields())
		fields.update(self._fields)		# important that this comes last
		return fields

	def addField(self, fieldName, typ_):
		assert isinstance(typ_, Typ)
		assert (typ_ != self)	 # recursion breaks everything
		if fieldName[:2] == "__":
			print("field names cannot begin with underscores")
		fieldName = fieldName.strip("_")

		# necessary if fullNames are hashes and separated by periods,
		# as opposed to some other string (eg, "|")
		if '.' in fieldName:
			print("field names cannot contain periods")
			fieldName = fieldName.replace('.', ';')

		self._fields[fieldName] = typ_

	# def getFieldTyp(self, fieldName):
	# 	return self._fields[fieldName]

	# def getId(self):
	# 	return self._id

	# -------------------------------
	# instantiation
	# -------------------------------

	def new(self):
		obj = self.defaultValue()
		typDict = {'__typ__': self}
		try:
			obj.update(typDict)
		except:
			# return a dict that only contains a type, rather
			# than the raw value
			# TODO do we want this behavior?
			# obj = typDict
			pass
		return obj

NUMBER = Typ("TypNumber", default=-1.0)
BOOL = Typ("TypBool", default=False)
STRING = Typ("TypString", default="")
COUNT = Typ("TypCount", default=-1)  # , fields={"Count", NUMBER})
RATING = Typ("Rating", default=-1)
AMOUNT = Typ("TypAmount", default=-1.0)
OTHER = Typ("Other", default="")

if __name__ == '__main__':

	# print(NUMBER.defaultValue())
	# print([typ.defaultValue() for typ in [NUMBER, BOOL]])
	# print([typ.defaultValue() for typ in NUMBER.allFields()])
	# print(BOOL.defaultValue())
	# print('bool all fields: ' + str(BOOL.allFields()))

	# import sys
	# sys.setrecursionlimit(12)
	# sys.exit()

	exer = Typ('exercise')
	emptyExer = exer.new()
	print(exer)
	# print('exercise fields: ' + str(exer.allFields()))
	exer.addField('name', STRING)
	print(exer)
	# print('exercise fields: ' + str(exer.allFields()))

	print emptyExer	 # None

	genericExer = exer.new()
	print genericExer  # doesn't have name field, cuz can't update with default
	genericExer['name'] = 'generic exercise'
	print genericExer  # has name field, but only cuz we added it to the dict

	male = Typ('male')
	bro = Typ('bro', parents=[male])
	lift = Typ('lift', parents=[exer, bro])
	print(lift)
	lift.addField('reps', COUNT)
	lift.addField('failure', BOOL)
	squats = lift.new()

	squats['name'] = 'squats'
	squats['reps'] = 2
	print(squats)

	print(NUMBER.new())		# the default value
