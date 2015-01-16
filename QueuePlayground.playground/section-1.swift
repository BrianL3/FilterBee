// Playground - an example of a queue datastructure

import UIKit

class Queue {
  var theQueue = ["firstInLine", "secondInLine", "thirdLine"]
  
  func push(getInLineSon: String){
    theQueue.append(getInLineSon)
  }
  
  func pop() -> String? {
    if let popped = self.theQueue.first {
      theQueue.removeAtIndex(0)
      return popped
    }else{
      return "the queue is empty"
    }
  }
  
  func peek() -> String? {
    return self.theQueue.first
  }
  
}

var myQueue = Queue()

myQueue.peek()
myQueue.push("fourthInLine")
myQueue.pop()
myQueue.pop()
myQueue.pop()
myQueue.pop()
myQueue.pop()

myQueue.peek()