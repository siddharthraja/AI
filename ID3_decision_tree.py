# CSE6242/CX4242 Homework 4 Pseudocode
# You can use this skeleton code for Task 1 of Homework 4.
# You don't have to use this code. You can implement your own code from scratch if you want.

import csv
import numpy as np
import sys
from math import log
import random

f = open("result.txt", "w")

# Defining the tree node
class Node:
	def __init__ (self, column = -1, branch = None, results = None):
		self.column = column
		self.branch = branch
		self.results = results


# To get the number of yes and no values
def target_value_count(rows):
  results = {}
  for row in rows:
    r = row[len(row) - 1]
    if r not in results: results[r] = 0
    results[r] += 1
  # f.write(str(results)+"|"+str(len(results)))
  return results

def entropy(rows):
  # to calculate the initial gain
  log2 = lambda x:log(x)/log(2)
  results = target_value_count(rows)

  entropy_value = 0.0
  for r in results.keys():
    p = float(results[r]) / len(rows)
    entropy_value = entropy_value - p * log2(p)

  return entropy_value
 
def attribute_entropy(rows, col):
	# attribute wise entropy calculation
	res = {}
	for row in rows:
		# stores each value of the first column
		if row[col] not in res: res[row[col]] = {'count': 0, 'y':0, 'n': 0, 'ent': 0.0}
		res[row[col]]['count'] += 1
		if str(row[len(row) - 1])=="yes": res[row[col]]['y'] += 1
		else: res[row[col]]['n'] += 1
		
	entropy_value = 0.0
	count = 0.0
	for r in res.keys():
		temp = res[r]
		py = float(temp['y']) / float(temp['count'])
		pn = float(temp['n']) / float(temp['count'])
		#print str(py) + " | " + str(pn)
		if py==0.0 or py==1.0: entropy_value = 0.0
		else:
			ent = - ( (py * log(py, 2)) + (pn * log(pn, 2)) )
			entropy_value = entropy_value + (float(temp['count']) / float(len(rows))) * ent
	
	# print "entropy value: " + str(entropy_value) + "....."
	# if entropy_value == 1.0:
	# print str(res.keys()) + " | " + str(len(rows))
	# print str(res)
	return entropy_value

# the multiple way split for the branches
def prepare_child_nodes(rows, col):
	nodes = {}

	for row in rows:
		if row[col] not in nodes: nodes[row[col]] = []
		nodes[row[col]].append(row)

	#print nodes.keys()
	return nodes

# Returning the leaf node when no more splitting is needed
def get_stopping_result(rows):
	results = target_value_count(rows)
	if len(results) == 2:
		if results['yes'] >= results['no']:
			return Node(results = {'yes': results['yes']})
		else:
			return Node(results = {'no': results['no']})
	else:
		return Node(results = results)

# Building the decision tree
def build_decision_tree(rows, attr_list):
	# handle base cases for recursion first
	# Then proceed to calculate the gain for each attribute and select the best
	if len(rows) == 0:
		return Node(results = None)
		
	val = 0
		
	if len(attr_list) == 0:
		return get_stopping_result(rows)

	current_score = entropy(rows)
	col = None
	best_col_gain = 0.0
	
	if current_score == 0.0:
		return get_stopping_result(rows) 
		#Node(results = target_value_count(rows))

	all_the_gains = []
	cols_done = []
	for temp_col in attr_list:
		if is_number(rows[0][temp_col]): 
			attr_list.remove(temp_col)
			continue
		col_ent = attribute_entropy(rows, temp_col)
		gain = current_score - col_ent
		all_the_gains.append(col_ent)
		cols_done.append(temp_col)
		if gain > best_col_gain:
			best_col_gain = gain
			col = temp_col
	

	# print str(current_score) + " | " + str(best_col_gain) + " | " + str(col)
	
	if col == None:
		# print str(attr_list)
		if len(cols_done) == 0: return get_stopping_result(rows)
		col = random.choice(cols_done) 


	if col in attr_list: attr_list.remove(col)
	children = prepare_child_nodes(rows, col)	
	
	curr_branch = {}
	for child in children.keys():
		curr_branch[child] = build_decision_tree(children[child], attr_list)

	return Node(column = col, branch = curr_branch)
		
# To determine if an attribute has numeric / continuous values
def is_number(s):
  try:
    float(s)
    return True
  except ValueError:
    return False

# Run the test_set 
def classify(instance, Dtree):
	if Dtree.results != None:
		return Dtree.results
	else:
		if Dtree.branch == None: return Dtree.results
		v = instance[Dtree.column]
		if v in Dtree.branch.keys():
			return classify(instance, Dtree.branch[v])
		else: 
			return Dtree.results

# This function creates discrete buckets for continuous variables
def process_cont_attributes(rows, col):
	vals = []
	for i in xrange(len(rows)):
		vals.append(rows[i][col])
	vals.sort()

	if vals[len(vals)/4] != vals[len(vals)/2] and vals[len(vals)/2] != vals[3*len(vals)/4]:
		for i in xrange(len(rows)):
			label = "X"
			if rows[i][col] < vals[len(vals)/4]: label = "A" + str(col)
			else:
				if rows[i][col] < vals[len(vals)/2]: label = "B" + str(col)
				else: 
					if rows[i][col] < vals[3*len(vals)/4]: label = "C" + str(col)
					else: label = "D" + str(col)
			rows[i][col] = label
	
	# if vals[len(vals)/3] != vals[2*len(vals)/3]:
		# for i in xrange(len(rows)):
			# label = "unknown"
			# if rows[i][col] < vals[len(vals)/3]: label = "A" + str(col)
			# else:
				# if rows[i][col] < vals[2*len(vals)/3]: label = "B" + str(col)
				# else: label = "C" + str(col)
			# rows[i][col] = label

	return rows

def run_decision_tree():
	with open("hw4-data.tsv") as tsv:
		  data = [tuple(line) for line in csv.reader(tsv, delimiter="\t")]
	print "Number of records: %d" % len(data)
	data = np.asarray(data)
	random.shuffle(data[len(data)/2:])
	accuracy = []
	attributes_list = []
	for x in xrange(len(data[0]) - 1):
		attributes_list.append(x)
	
	for x in xrange(len(data[0]) - 1):
		if is_number(data[0][x]):
			data = process_cont_attributes(data, x)
			
	tree = None

	K = 10
	for cv_count in xrange(10):
		training_set = [x for i, x in enumerate(data)  if i % K != cv_count]
		test_set = [x for i, x in enumerate(data)  if i % K == cv_count]
		tree = build_decision_tree(training_set, attributes_list)
		# Classify the test set using the tree we just constructed
		results = []
		for instance in test_set:
			result = classify( instance[:-1], tree)
			if result == None: results.append(False)
			else: results.append( result.keys()[0] == instance[-1] )
		accuracy_curr = float(results.count(True))/float(len(results))
		accuracy.append(accuracy_curr)
		tree = None

	avg_acuracy = (sum(accuracy) / len(accuracy))
	print "\nAccuracies for each Fold: " + str(accuracy)
	print "Overall Accuracy: %.4f" % avg_acuracy

	# Writing results to a file (DO NOT CHANGE)

	f.write("accuracy: %.4f" % avg_acuracy)
	f.close()

if __name__ == "__main__":
	run_decision_tree()