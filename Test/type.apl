include stdlib

TypeNames = MakeArray("����", "С��", "����ֵ", "�ַ���", "����")

private a

function ShowInfo()
  Writeln("a = ", a, " ����Ϊ:", TypeNames[Type(a)])
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

