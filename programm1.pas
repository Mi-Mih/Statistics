program matstat;

const n   =10;
const k   =9;

var
   {Массивы координата(время), учитывай k - количество точек и n кол-во измерений}
   time,x: array [0..k] of real; {k}
   eps, t_upr:real;
   err_norm, t_upr_arr, err_upr:array [0..n] of real; {n}
   i,j:integer;
   x_zas, time_zas,err_num: array[0..100-2] of real;
   f:text;
   {массив, содержащий 2 коэффа b_0 и b_1}
   solution:array [0..1] of real;
   
Function power (os: real; st: integer):real;
            {Возведение вещественного числа   в  целочисленную  степень.}
                     begin
                       if st < 0 then
                          power:=1/power(os,abs(st))
                       else
                         if st > 0 then
                            power:=os*power(os,st-1)
                         else
                            power:=1;
                     end; {функции power} 
 Function Powd(a,b: real): real;
            {Возведение вещественного числа  в вещественную степень.}
                      begin
                        if a > 0 then
                                 powd:=exp(b*ln(a))
                        else
                          if a < 0 then
                                   powd:=exp(b*ln(abs(a)))
                          else
                            if b = 0 then powd:=1
                            else powd:=0;
                      end;   {Powd}
 {нормальный датчик (0,1) }
                 Function DAHOP(): real;
                     {   Var
                     i    : byte;
                     a,aa : real;
                       begin
                         a:=0;
                         for i:=1 to 12 do
                           begin
                             aa:=random;
                             a:=a+aa;
                           end;
                         Dahop:=(a-6)/0.6745;
                       end;  }
                   var
                   ra:real;
                   begin
                   ra:=abs(exp((-1/2)*(power(random,2)))/sqrt(2*pi));
                   end;

{фунция МНК, прямая}
function MNK(var coord,time,solution: array of real): boolean;
      var
      {index массива}
         i : integer ;
         {размер массива}
         n: integer;
         {вспомогательные массивы сумм для МНК}
         sum_coord:real;
         sum_t:real;
         sum_t_2:real;
         sum_coord_t:real;
         {Искомые коэффициенты}
         b_0:real;
         b_1:real;
      begin
         sum_coord:=0;
         sum_t:=0;
         sum_t_2:=0;
         sum_coord_t:=0;
      {размер берём по массиву времени}
      n:=length(time);

      {ищем прямую y=b_0+b_1*x}
      {считаем необходимые суммы: sum(coord), sum(t^2),sum(t),sum(coord*t)}
      for i:=0 to n-1 do
      begin
            sum_coord := sum_coord + coord[i];
            sum_t_2:=sum_t_2+power(time[i],2);
            sum_t:=sum_t+time[i];
            sum_coord_t:=sum_coord_t+time[i]*coord[i];
      end;
      {b_0}
      b_0:=(sum_coord*sum_t_2-sum_t*sum_coord_t)/(n*sum_t_2-power(sum_t,2));
      {b_1}
      b_1:=(n*sum_coord_t-sum_t*sum_coord)/(n*sum_t_2-power(sum_t,2));

      {то, что возвращаем: массив найденных коэффов}
      solution[0]:=b_0;
      solution[1]:=b_1;
end;
Function x_exact(t: real): real;
                      begin
                        result:=20+45*t;
                      end;
Function x_predict(b_0,b_1,x_p:real):real;
          var
             pred:real;
         begin
         pred:=b_0+b_1*x_p;
         end;


begin
assign(f,'data.csv');
rewrite(f);
writeln(f,'Ошибка от возмущения');

{Ошибка от возмущения}
t_upr:=1;
for i:=0 to n do
begin
eps:=DAHOP();
for j:=0 to k do
begin
x[j]:=x_exact(j)+eps;
time[j]:=j;
end;
MNK(x,time,solution);
{writeln('y=',solution[0],'+',solution[1],'*x');}
err_norm[i]:=abs(x_exact(k+t_upr)-x_predict(solution[0],solution[1],k+t_upr));

writeln(f,err_norm[i]);
end;

writeln(f,'время упреждения');
{Ошибка от время упреждения }
eps:=DAHOP();
t_upr:=1;
for j:=0 to k do
begin
x[j]:=x_exact(j)+eps;
time[j]:=j;
end;
for i:=0 to n do
      begin
         t_upr:=t_upr+i;
         t_upr_arr[i]:=t_upr;
         MNK(x,time,solution);
err_upr[i]:=abs(x_exact(k+t_upr)-x_predict(solution[0],solution[1],k+t_upr));
writeln(f, t_upr_arr[i]);
end;
writeln(f,'Ошибка от время упреждения при eps=', eps);
for i:=0 to n do
begin
writeln(f,err_upr[i]);
end;



writeln(f,'Ошибка от числа засечек');
{Ошибка от числа засечек}
eps:=DAHOP();
t_upr:=1;
for i:=2 to 100 do
begin
for j:=0 to i do
begin
   time_zas[j]:=j;
   x_zas[j]:=x_exact(j)+eps;
end;
MNK(x_zas,time_zas,solution);
err_num[i-2]:=abs(x_exact(i+t_upr)-x_predict(solution[0],solution[1],i+t_upr));

writeln(f,i);
end;
writeln(f,'Ошибка от числа засечек при eps=',eps,'t_upr',t_upr);
for i:=0 to 100-3 do
begin
writeln(f,err_num[i]);
end;
close(f);
end.
