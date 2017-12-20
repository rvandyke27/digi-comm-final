

class Connection:


	def __init__ (self, sending_node, receiving_node, attenuation):

		self.sending_node = sending_node
		self.receiving_node = receiving_node
		self.attenuation = attenuation

	#	receiving_node.backoff = int(float(sending_node.message.length/40000)*1000)
		receiving_node.received = sending_node.message.data


		if(sending_node.message.ack == True):
			#receiving node receives ack after sending nodes message has been fully transmitted (this is simulated by settign the backoff time of the receiving node)
			#print(int(float(sending_node.message.length/40000)*1000))
			#receiving_node.backoff = int(float(sending_node.message.length/40000)*1000) - 1

			receiving_node.message.data = "ack"
			receiving_node.message.length = 248
			receiving_node.message.ack = False
			#receiving_node.message = Message(1)
			receiving_node.transmit(sending_node)

