USE [Okul]

--Ilgili Donemdeki Ilgili Ogrencinin Aldigi Dersin Sayi Degeri:
--girdiler: ogrenci @Ogrenci_Id int,Ders_Id ,Donem_Id 
--cıktı : sayi degeri



ALTER FUNCTION [dbo].[FN$IlgiliDonemdekiOgrencininAldigiDersinSayiDegeri] 
(
 @Ogrenci_Id int,
 @Ders_Id int,
 @Donem_Id int
)
RETURNS tinyint
AS 
    BEGIN
	 declare @HarfNotu char(2),
	         @Ortalama decimal(18,2),
			 @KrediSayisi tinyint,
			 @HarfNotununSayiDegeri tinyint,
			 @DersinSayiDegeri tinyint

 select @Ortalama = ood.Vize*0.4+ood.Final*0.6,
        @KrediSayisi = d.KrediSayisi
 from dbo.[OgrenciOgretmenDers] as ood
 inner join dbo.OgretmenDers as od on od.Id = ood.OgretmenDers_Id and od.Statu = 1
 inner join dbo.Ders as d on d.Id = od.Ders_Id and d.Statu = 1
 where ood.Statu = 1
 and ood.Ogrenci_Id = @Ogrenci_Id
 and od.Ders_Id  =@Ders_Id
 and od.Donem_Id = @Donem_Id

 set @Ortalama = ROUND(@Ortalama,0)

 SET @HarfNotu = (SELECT 
       case when @Ortalama between 93 and 100 then  'AA'
	        when @Ortalama between 85 and 92  then  'BA'
	        when @Ortalama between 76 and 84  then  'BB'
	        when @Ortalama between 66 and 75  then  'CB'
			when @Ortalama between 46 and 65  then  'CC'
			when @Ortalama between 31 and 45  then  'DC'
			when @Ortalama between 15 and 30  then  'DD'
	   else 'FF' end )

SET @HarfNotununSayiDegeri = (SELECT 
       case when @HarfNotu='AA' then  4
	        when @HarfNotu='BA' then  3.5
	        when @HarfNotu='BB' then  3
	        when @HarfNotu='CB' then  2.5
			when @HarfNotu='CC' then  2
			when @HarfNotu='DC' then  1.5
			when @HarfNotu='DD' then  1
	   else 0 end)

SELECT @DersinSayiDegeri = @HarfNotununSayiDegeri*@KrediSayisi 

	 return @DersinSayiDegeri

	 end




--cagiralim:
select [dbo].[FN$IlgiliDonemdekiOgrencininAldigiDersinSayiDegeri] (2,5,1)








--where clause kontrolu:	 
declare 
 @Donem_Id int = 1,
 @Ogrenci_Id int= 2
 
select A.*,
      case  when a.DerseAitHarfNotu='AA' then  4
	        when a.DerseAitHarfNotu='BA' then  3.5
	        when a.DerseAitHarfNotu='BB' then  3
	        when a.DerseAitHarfNotu='CB' then  2.5
			when a.DerseAitHarfNotu='CC' then  2
			when a.DerseAitHarfNotu='DC' then  1.5
			when a.DerseAitHarfNotu='DD' then  1
	   else 0 end as HarfDegeri
from (
select ood.Ogrenci_Id,
       od.Donem_Id,
	   d.Id as Ders_Id,
	   dbo.FN$IlgiliDonemdekiOgrencininDersHarfNotu(@Ogrenci_Id,d.Id,@Donem_Id) as DerseAitHarfNotu	, 
	   dbo.FN$IlgiliDonemdekiOgrencininAldigiDersinSayiDegeri(@Ogrenci_Id,d.Id,@Donem_Id) as DersinSayiDegeri,
	   d.KrediSayisi as KrediSayisi 
	    
from dbo.OgrenciOgretmenDers as ood 
inner join dbo.OgretmenDers as od on od.Id=ood.OgretmenDers_Id and od.Statu=1
inner join dbo.Ders as d on d.Id=od.Ders_Id and d.Statu=1
inner join dbo.Ogrenci as o on o.Id=ood.Ogrenci_Id and o.Statu=1
inner join dbo.Donem as do on do.Id=od.Donem_Id and do.Statu=1
where 
ood.Statu=1
and do.Id = @Donem_Id
and ood.Ogrenci_Id=@Ogrenci_Id
)A
