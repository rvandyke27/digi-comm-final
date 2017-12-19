
import sys
from node import Node
import random
from message import Message
class Medium:

	def __init__(self, num_controllers, num_controlled_devices, packet_loss_rate):

		self.num_controllers = num_controllers
		self.num_controlled_devices = num_controlled_devices
		self.packet_loss_rate = packet_loss_rate

		self.total_devices = self.num_controllers + self.num_controlled_devices
		#create list of all devices
		self.node_list = list()
		self.controller_list = list()
		self.device_list = list()
		for i in range(self.num_controllers):
			node = Node("controller")
			self.node_list.append(node)
			self.controller_list.append(node)

		for i in range(self.num_controlled_devices):
			node = Node("controlled_device")
			self.node_list.append(node)
			self.device_list.append(node)


		#initialize channel as idle
		self.busy = False 

def main():
		num_controllers = int(sys.argv[1])
		num_controlled_devices = int(sys.argv[2])
		packet_loss_rate = float(sys.argv[3])
		runtime = int(sys.argv[4])
		traffic = float(sys.argv[5])
		medium = Medium(num_controllers, num_controlled_devices, packet_loss_rate)
		last_sender = 0
		# for node in medium.node_list:
		# 	node.printNode()

		#simulation is conducted in discrete time intervals where each loop represents 1 msec

#		medium.node_list[3].transmit(medium.node_list[8])

		if(traffic <= 0):
			print("Not a valid traffic value")

		transmit_probability = float(traffic)/10000.0
		print("transmit probability: ", transmit_probability)

		busy_counter = 0
		transmissions = 0
		attempts = 0
		ready_controllers = 0
		num_acks = 0
		for i in range(runtime*1000):

			if (i % 100 == 0):
				print(i, " milliseconds")

			busy_counter = busy_counter - 1

			#randomly decide which nodes have data to transmit based on traffic parameter
			for node in medium.controller_list:
				#if( (node.message.length == 0) and (random.random() < transmit_probability) ):
				node.message = Message(transmit_probability)
			#	node.message.length = 8*random.randint(20,140)	
					
			if(busy_counter > 0):
				medium.busy = True


			else:
				medium.busy = False			


			# "send" clear channel assessment based on if medium is busy 
			for node in medium.node_list:
				node.cca = not (medium.busy)


			index = 0
			for node in medium.node_list:
				index = index + 1
				if(node.message.length > 0):
					if(node.transmit(medium.device_list[random.randint(0, len(medium.device_list) - 1)])):
						busy_counter = int(40000/node.message.length)
						node.message.length = 0
						node.message.data = ""
						if(node.message.data != "ack"):
							transmissions = transmissions + 1
							attempts = attempts + 1
						# elif(node.message.data == "ack"):
						# 	num_acks = num_acks + 1
						for node in medium.node_list[index:]:
							node.message.length = 0
							node.message.data = ""
					else:
						if(node.message.data != "ack"):
							attempts = attempts + 1






		print("Successful Transmissions: ", transmissions)
		print("Drops: ", Node.drops)
		print("ACKS: ", Node.acks)
		#if(attempts > 0): print("Success Rate: ", float(transmissions/attempts))




if __name__=="__main__":
	main()	