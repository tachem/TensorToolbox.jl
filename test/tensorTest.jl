using TensorToolbox
using Base.Test

println("\n\n**** Testing tensor.jl")

X=rand(20,10,50,5)
N=ndims(X)
println("\n**Test tensor X of size: ", size(X))

println("\n...Testing functions matten and tenmat (by mode).")
for n=1:N
  Xn=tenmat(X,n);
  M=setdiff(1:N,n);
  println("Size of $n-mode matricization: ", [size(Xn)...])
  @test size(Xn) == (size(X,n),prod([size(X,M[k]) for k=1:length(M)]))
  println("Check if it folds back correctly: ",matten(Xn,n,[size(X)...]) == X)
  @test matten(Xn,n,[size(X)...]) == X
end

println("\n...Testing functions matten and tenmat (by rows and columns).")
R=[2,1];C=[4,3];
Xmat=tenmat(X,R=R,C=C);
println("Size of R=$R and C=$C matricization: ", [size(Xmat)...])
println("Check if it folds back correctly: ",matten(Xmat,R,C,[size(X)...]) == X)
@test matten(Xmat,R,C,[size(X)...]) == X

println("\n...Testing function ttm.")
M=MatrixCell(N)
for n=1:N
  M[n]=rand(5,size(X,n))
end
println("Created $N matrices with 5 rows and appropriate number of columns.")
Xprod=ttm(X,M)
println("Size of tensor Y=ttm(X,M): ",size(Xprod))
err=vecnorm(tenmat(Xprod,1) - M[1]*tenmat(X,1)*kron(M[end:-1:2])')
println("Multiplication error: ",err)
@test err ≈ 0 atol=1e-10

println("\n...Testing function ttv.")
Xk=reshape(collect(1:24),(3,4,2))
n=2
v=collect(1:4)
println("Multiplying a tensor X by a vector v in mode $n.")
Xprod=ttv(Xk,v,n)
println("Size of tensor Y=ttv(X,v): ",size(Xprod))
res=[70 190;80 200;90 210]
@test Xprod==res

println("\n...Testing function krontm.")
X=rand(5,4,3)
Y=rand(2,5,4)
println("Created two tensors X and Y of order ",ndims(X)," and sizes ",size(X)," and ",size(Y),".")
mode=3
M1=rand(20,10)
M2=rand(20,20)
M3=rand(20,12)
println("Multiplying tkron(X,Y) by random matrix in mode $mode.")
Z=krontm(X,Y,M3,mode)
err= vecnorm(Z-ttm(tkron(X,Y),M3,mode))
println("Multiplication error: ",err)
@test err ≈ 0 atol=1e-10
mode=[3,2]
M=[M3,M2]
println("Multiplying tkron(X,Y) by random matrices in modes $mode.")
Z=krontm(X,Y,M,mode)
err = vecnorm(Z-ttm(tkron(X,Y),M,mode))
println("Multiplication error: ",err)
@test err ≈ 0 atol=1e-10
M=[M1,M2,M3]
println("Multiplying tkron(X,Y) by random matrices in all modes.")
Z=krontm(X,Y,M)
err = vecnorm(Z-ttm(tkron(X,Y),M))
println("Multiplication error: ",err)
@test err ≈ 0 atol=1e-10

println("\n...Testing function mkrontv.")
v=rand(240)
n=1
println("Multiplying mode-$n matricized tkron(X,Y) by a random vector.")
Z=mkrontv(X,Y,v,n)
err = vecnorm(Z-tenmat(tkron(X,Y),n)*v)
println("Multiplication error: ",err)
@test err ≈ 0 atol=1e-10
v=rand(10)
Z=mkrontv(X,Y,v,n,'t')
err = vecnorm(Z-tenmat(tkron(X,Y),n)'*v)
println("Multiplication error: ",err)
@test err ≈ 0 atol=1e-10

println("\n...Testing function mttkrp.")
X=rand(5,4,3)
n=1
A1=rand(2,5);
A2=rand(4,5);
A3=rand(3,5);
A=[A1,A2,A3]
println("Multiplying mode-$n matricized tensor X by Khatri-Rao product of matrices.")
Z=mttkrp(X,A,n)
err = vecnorm(Z-tenmat(X,n)*khatrirao(A3,A2))
println("Multiplication error: ",err)
@test err ≈ 0 atol=1e-10

println("\n...Testing function squeeze.")
X=rand(5,4,1,3,6,1);
Xsq=squeeze(X);
println("Tensor X of size :",size(X)," squeezed to size :",size(Xsq),".")
