include stdlib

TypeNames = MakeArray("整数", "小数", "布尔值", "字符串", "数组")

private a

function ShowInfo()
  Writeln("a = ", a, " 类型为:", TypeNames[Type(a)])
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

