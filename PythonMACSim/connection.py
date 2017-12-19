

class Connection:


	def __init__ (self, sending_node, receiving_node, attenuation):

		self.sending_node = sending_node
		self.receiving_node = receiving_node
		self.attenuation = attenuation

		receiving_node.received = sending_node.message.data


		if(sending_node.message.ack == True):
			receiving_node.message.data = "ack"
			receiving_node.message.length = 4
			receiving_node.message.ack = False
			#receiving_node.message = Message(1)
			receiving_node.transmit(sending_node)

