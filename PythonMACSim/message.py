
import random
class Message:


	def __init__ (self, probability):

		d = random.randint(0,4)

		if(random.random() < probability):
			if(d == 0): 
				self.data = "TURN LIGHT ON"
				self.ack = False
				self.length = 8*len(self.data)
			elif(d == 1): 
				self.data = "CLOSE THE BLINDS"
				self.length = 8*len(self.data)
				self.ack = False
			elif(d == 2): 
				self.data = "MAKE COFFEE"
				self.length = 8*len(self.data)
				self.ack = False
			elif(d == 3): 
				self.data = "TURN UP THE AC"
				self.length = 8*len(self.data)
				self.ack = False
			elif(d == 4): 
				self.data = "FOLLOW YOUR HEART"
				self.length = 8*len(self.data)
				self.ack = True
			#self.ack = True
		else:
			self.data = ""
			self.length = 0

