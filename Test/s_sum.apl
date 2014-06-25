include stdlib

function sum1(x, f)
  sumx = 0
  for i = 0 to x.Len() - 1
    push x[i]
    a = CallAt(f)
    sumx=sumx+a
  next
end sumx

function sum2(x, y, f)
  sumx = 0
  for i = 0 to x.Len() - 1
    push x[i]
    push y[i]
    a = CallAt(f)
    sumx=sumx+a
  next
end sumx

function a(x)
end x

function sqr(x)
end x*x

function xy(x,y)
end x*y

ut = MakeArray(17.66, 18.06, 18.56, 19.06, 19.56,20.06, 20.56,21.06,22.50)
up = MakeArray(3.60, 4.29, 6.16, 7.97, 9.82,11.60, 13.36,15.12, 20.21)
tb = 99.95
ar = 4.26*0.001
kp = 7.676*0.0001
utb = ut[ut.Len()-1]
u0 = 3.95
t = NewArray(ut.Len())
pc = 101110
for i = 0 to ut.Len()-1
  t[i] = ut[i]/utb*(1/ar+tb)-1/ar
  Writeln("t[",i,"] = ", t[i])
next

p = NewArray( up.Len() )
for i = 0 to up.Len()-1
  p[i] = pc+(up[i]-u0)/kp
  Writeln("p[",i,"] = ", p[i])
next
sumt = sum1(t,a)
sumtt = sum1(t,sqr)
sumtp = sum2(t,p,xy)
sump = sum1(p,a)
avgt = sumt / t.Len()
avgp = sump / p.Len()


dt = NewArray(t.Len())
for i = 0 to up.Len()-1
  dt[i] = t[i] - avgt
next
dp = NewArray(p.Len())
for i = 0 to up.Len()-1
  dp[i] = p[i] - avgp
next
sumdtdp = sum2(dt,dp,xy)
sumdtdt = sum1(dt,sqr)
sumdpdp = sum1(dp,sqr)
A = (sumtp*sumt - sump*sumtt)/(sumt*sumt - ut.Len()*sumtt)
Writeln(A)
B = (sumt*sump - ut.Len()*sumtp)/(sumt*sumt - ut.Len()*sumtt)
Writeln(B/A)
R = sumdtdp/Sqrt(sumdtdt*sumdpdp)
Writeln(R)
Writeln((0.018+5*0.02)+3.36)

