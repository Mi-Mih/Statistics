
{фунция МНК, прямая}
function MNK(var coord,time: array of real; input:real): real;
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
         output:real;
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
      output:=b_0+b_1*input;
end;
