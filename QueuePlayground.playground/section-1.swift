// Playground - an example of a queue datastructure

import UIKit

class Queue {
  var theQueue = ["firstInLine", "secondInLine", "thirdLine"]
  
  func enqueue(getInLineSon: String){
    theQueue.append(getInLineSon)
  }
  
  func dequeue() -> String? {
    if let deQd = self.theQueue.first {
      theQueue.removeAtIndex(0)
      return deQd
    }else{
      return nil
    }
  }
  
  func peek() -> String? {
    return self.theQueue.first
  }
  
}

var myQueue = Queue()

myQueue.peek()

myQueue.enqueue("fourthInLine")

myQueue.dequeue()
myQueue.dequeue()
myQueue.dequeue()
myQueue.dequeue()
myQueue.dequeue()

myQueue.peek()
