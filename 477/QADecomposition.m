A = randn(100,100);
B = A * A';
B = 1/2*(B+B');
Ao = B;
for i=1:100
    [Q,R]=qr(Ao);
    Ao   =R*Q;
end
x = eig(B);