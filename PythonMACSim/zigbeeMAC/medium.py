
import sys
from node import Node
import random
from message import Message
import matplotlib.pyplot as plt

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



#	num_controllers = int(sys.argv[1])
#	num_controlled_devices = int(sys.argv[2])
#	packet_loss_rate = float(sys.argv[4])
	runtime = int(sys.argv[1])
	#traffic = float(sys.argv[5])
#	medium = Medium(num_controllers, num_controlled_devices, packet_loss_rate)
	big_list = list()

	list_slist = list()
	list_dlist = list()

		#simulation is conducted in discrete time intervals where each loop represents 1 msec

		# if(traffic <= 0):
		# 	print("Not a valid traffic value")
	for i in range(10):
		num_controllers = 2*(i+1)
		num_controlled_devices = 20*(i+1)
		medium = Medium(num_controllers, num_controlled_devices, 0)			
		s_list = list()
		d_list = list()
		throughput_dict = {}
		for traffic in range(5):
			transmit_probability = float(traffic + 1)/100000.0
			print("transmit probability: ", transmit_probability)
			busy_counter = 0
			transmissions = 0
			attempts = 0
			ready_controllers = 0
			num_acks = 0
			for i in range(runtime*1000):

				# if (i % 100 == 0):
				# 	print(i, " milliseconds")

				busy_counter = busy_counter - 1

				#randomly decide which nodes have data to transmit based on traffic parameter
				for node in medium.controller_list:
					#if( (node.message.length == 0) and (random.random() < transmit_probability) ):
					node.message = Message(transmit_probability)
				#	node.message.length = 8*random.randint(20,140)	

				# for node in medium.device_list:
				# 	if(random.random() < sleep_probability):
				# 		node.awake = False
						
				if(busy_counter > 0):
					medium.busy = True


				else:
					medium.busy = False			


				#clear channel assessment based on if medium is busy 
				for node in medium.node_list:
					node.cca = not (medium.busy)


				index = 0
				for node in medium.node_list:
					index = index + 1
					if(node.message.length > 0):
						if(node.transmit(medium.device_list[random.randint(0, len(medium.device_list) - 1)])):
							busy_counter = int(float(node.message.length/40000)*1000)
							node.message.length = 0
							node.message.data = ""
							if(node.message.data != "ack"):
								transmissions = transmissions + 1
								attempts = attempts + 1
							
							for node in medium.node_list[index:]:
							 	node.message.length = 0
							 	node.message.data = ""
						else:
							if(node.message.data != "ack"):
								attempts = attempts + 1

				Node.nodeID = 0


			print("Successful Transmissions: ", transmissions)
			print("Drops: ", Node.drops)
			print("Attempts: ", attempts)
		#	print("Acks:", Node.acks)
			s_list.append(transmissions)
			d_list.append(Node.drops)
			transmissions = 0
			Node.drops = 0
			Node.acks = 0

		list_slist.append(s_list)
		list_dlist.append(d_list)
	
	



	plt.figure(1)
	for i in range(len(list_slist)):
		plt.subplot(2,5,i+1)
		plt.plot([1,2,3,4,5], list_slist[i], 'g')#, label = "Successful Transmissions")
		plt.plot([1,2,3,4,5], list_dlist[i], 'r')#,label = "Dropped Packets")
		plt.axis([1, 5, 0, 100])
	#	plt.xlabel()

		plt.title(str(2*(i+1) + 20*(i+1)) + " Total Devices", fontsize = 8)
		plt.xlabel("Traffic Level (10^-3 %)", fontsize = 6)
	plt.loc = "lower right"
	plt.legend()
	plt.show()


	
	#plt.show()

if __name__=="__main__":
	main()	