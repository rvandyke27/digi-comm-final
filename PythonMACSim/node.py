from message import Message
import random
from connection import Connection
class Node:

	nodeID = 1
	drops = 0
	acks = 0

	def __init__ (self, node_type):

		self.nodeID = Node.nodeID
		Node.nodeID = Node.nodeID + 1
		self.node_type = node_type

		self.message = Message(0)
		self.received = ""
		self.awake = True
		self.want_transmit = False

		#Clear Channel Assessment - True if channel is clear and False if channel is busy
		self.cca = True
		self.backoff = 0
		#data_FIFO = Queue()
		self.attempt_num = 0

	def printNode(self):
		print("Node ID: ", self.nodeID, " ... Node Type: ", self.node_type)


	def transmit(self, destination):

	#	print("function test")
		#print("attempting transmission from node ", self.nodeID, " to node ", destination.nodeID)
		#print(self.cca)
		#transmit if channel not busy and backoff finished

		#if unsuccesful max_try attempts, give up and indicate that transmission failed 
		if(self.attempt_num == 5):
			self.attempt_num = 0
			self.message.length = 0
			self.message.data = ""
			Node.drops = Node.drops + 1
			print("TOO MANY TRIES ... DROPPING DATA AND GIVING UP")
			return False

		#if channel is clear and node not in backoff, transmit data
		if(self.cca == True and self.backoff == 0):

			print ("[Node ", self.nodeID, "] -------", self.message.data, "------------->", "[Node ", destination.nodeID, "]"  )
			self.attempt_num = 0
			if(self.message.data == "ack"):
				Node.acks = Node.acks + 1


		#if receiver is awake then set received data of destination of sending nodes message with probability (1 - packet_loss_rate)
			if(destination.awake == True):
					connection = Connection(self, destination, 0)
			return True

		#if channel is busy then wait randomly chosen value between 10 and 40 loops and try again
		elif(self.cca == False and self.backoff == 0):
			self.backoff = random.randint(10, 40)
			self.attempt_num = self.attempt_num + 1
			return False

		#if still in backoff, just decrement counter and wait for next loop
		elif(self.backoff > 0):
			self.backoff = self.backoff - 1
			self.attempt_num = self.attempt_num + 1
			return False

		else:
			return False




