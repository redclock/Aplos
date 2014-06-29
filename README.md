Aplos
=====

Scripting language. The source code of the compiler is written in Delphi.

###Sample Code
```
include stdlib

TypeNames = MakeArray("Integer", "Float", "Boolean", "String", "Array")

private a

function ShowInfo()
  Writeln("a = ", a, " Type is:", TypeNames[Type(a)])
end

a = 1
ShowInfo()

a = 1.1
ShowInfo()


a = 3 > 2
ShowInfo()


a = "Hello world"
ShowInfo()


a = NewArray(10)
a[1] = "This is a[1]"
a[2] = NewArray(3)
a[2][1] = 1>1
ShowInfo()
```
Result:
```
a = 1 Type is:Integer
a = 1.1 Type is:Float
a = TRUE Type is:Boolean
a = Hello world Type is:String
a = (0,This is a[1],(0,FALSE,0),0,0,0,0,0,0,0) Type is:Array
```


