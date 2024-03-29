//examples compatibility among types

proc main(): void{
	return;
}

var myBool: bool = false;
var myInt: int = 5;
var myChar: char = 'a';
var myReal: real = 0.99;
var myString: string = "ciao";

proc check_type(): void{

	myInt = myBool; // compatible
	myInt = myChar; // compatible

	myReal = myInt; //compatible	
	myReal = myBool; // compatible
	myReal = myChar; // compatible
	
	myString = myChar; //error not compatible
	myString = myBool; //error not compatible
	myString = myInt; //error not compatible
	myString = myReal; //error not compatible
	
	myChar = myString; //error not compatible
	myChar = myInt; //error not compatible
	myChar = myReal; //error not compatible
	myChar = myBool; //error not compatible

	myBool = myString; //error not compatible
	myBool = myChar; //error not compatible
	myBool = myInt; //error not compatible
	myBool = myString; //error not compatible

	myChar = myBool + myBool; //  error not compatible
	myChar = myBool + myInt; //  error not compatible

	myBool = myChar + myChar; // error not compatible
	myBool = myBool + myInt; //  error not compatible

	myInt = myBool + myBool; // correct
	myInt = myBool + myChar; // correct
	myInt = myChar + myChar; // correct

	myReal = myReal + myInt; // correct
	myReal = myBool + myBool; // correct
	myReal = myBool + myChar; // correct
	myReal = myChar + myChar; // correct

	myString = myReal + myInt; // error compatibility btw types


	return;
}
