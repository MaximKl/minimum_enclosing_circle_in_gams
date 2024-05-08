* Задання кількості вкладених кіл
Sets i / i1 * i10 /;
alias(i, j);
set ij(i,j);

ij(i,j)$(ord(i) < ord(j)) = yes;

scalar k, globmin;
globmin = inf;

* Параметр для радіусів
parameters
    r(i); 

* Заповнення параметра r відповідно до формули r_i = 2i + 2
r(i) = 2*ord(i) + 2;

variables rc, x(i), y(i), gx(i), gy(i);
equations circumscribe(i), nooverlap(i,j);

circumscribe(i).. (rc-r(i))*(rc-r(i)) =g= x(i)*x(i) + y(i)*y(i);
nooverlap(ij(i,j)).. (x(i)-x(j))*(x(i)-x(j)) + (y(i)-y(j))*(y(i)-y(j)) =g= (r(i)+r(j))*(r(i)+r(j));

x.lo(i) = -100.; x.up(i) = 100.;
y.lo(i) = -100.; y.up(i) = 100.;
rc.lo = 0.05; rc.up = 100;

option nlp=ipopt;

model m /all/;

for(k=1 to 10,
    x.l(i) = uniform(-50, 50);
    y.l(i) = uniform(-50, 50);
    solve m using nlp minimizing rc;
    if (m.modelstat = 2 and rc.l le globmin,
        globmin = rc.l;
        gx.l(i) = x.l(i);
        gy.l(i) = y.l(i);
    );
);
         
display globmin,gx.l,gy.l, r;

* Створення таблиці для збереження даних
set data /'globmin', 'gx', 'gy', 'r'/;
parameter results(data, i);
results('globmin', i) = globmin;
results('gx', i) = gx.l(i);
results('gy', i) = gy.l(i);
results('r', i) = r(i);

* Збереження даних у файл
execute_unload 'mydata.gdx', results;
execute 'gdxxrw.exe mydata.gdx o=plots/mydata.xlsx par=results rng=data!a1';