param myConst: int = 3;
var myInt: [5]int = [1,2,3,4,5];
var myBool: bool = false;

proc nyFunction(x:int, y:real) : real {
  
  var newResult: real = 0.0;
  var counter: int = 0;
  var x:int = 0;

  while myBool {
    if counter == x then myBool = true;
    readInt(myInt[counter]); // error number of parameters
    counter+=1;
  }
  break; // error break outside a loop, gives error with continue as well
  while true do x+=1;

  for x in {counter..10} do writeInt(myInt[x]);

  for y in {1 .. 20}
   {
    if false
    {
      var p:int = 0;
      while false
      {
        for x in {counter..10} do writeInt(myInt[x]);
      }
    }
    else {
          var x:int = 0;
          y+=1; // error cannot modify the iterator
          y+=1;}
   }

  return newResult; 
  }


proc main(): void{
  return;
}