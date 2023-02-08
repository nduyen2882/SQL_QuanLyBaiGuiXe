--FUNCTION--
--1. Hàm trả về số chỗ đỗ còn trống tại 1 thời điểm với tham số truyền vào là thời gian
create function f_ChoTrong(@ThoiGian datetime)
returns int
as
begin 
	declare @SoLuong int, @SLT int, @KQ int
	select @SoLuong= count(ChoDo.IDCho) 
	from ChoDo
	select @SLT = count(PhuongTien.IDCho) from PhuongTien 
	where @ThoiGian between PhuongTien.GioVao and PhuongTien.GioRa
	set @KQ= @SoLuong-@SLT
	return @KQ
end
print dbo.f_ChoTrong('2020-10-10 18:00:00')
--2. Hàm đếm số lượng xe đang đỗ theo khu với tham số truyền vào là mã Khu
select * from PhuongTien, ChoDo where PhuongTien.IDCho=ChoDo.IDCho;
select * from ChoDo;
create function f_SLXe(@Khu char(1))
returns int
as
begin 
	declare @Slg int
	select @Slg=count(BienSo) from PhuongTien 
	where IDCho like concat(@Khu,'%') and GioRa is null
	return @Slg
end
print dbo.f_SLXe('A');
--3.Hàm tính lương nhân viên theo số năm làm việc với tham số truyền vào là iDNV
select * from ChoDo;
create function f_LuongNV(@idNV int)
returns int
as begin
	declare @Years int, @Count int =0, @Tien int, @Luong int;
	select @Years=datepart(year,getdate())-(datepart(year,NgayBatDau)), @Tien= LuongTheoNgay*SoNgayLam
	from NhanVien, ChucVu 
	where IDNV=@idNV and NhanVien.ViTriLam=ChucVu.ViTriLam;
	while @Count<@Years
	begin
		set @Tien=@Tien + @Tien*0.1;  
		set @Count=@Count+1;
	end
	return @Tien
end
print dbo.f_LuongNV(2)
select * from NhanVien;
select * from PhuongTien;
--4. Hàm trả về số lượng nhân viên quản lý mỗi khu với tham số truyền vào là khu
create function f_SLNV(@Khu char(1))
returns int
as
begin
	declare cur_1 cursor
	scroll
	for 
	 select IDCho, IDNV from NVQLCD;
	open cur_1
	declare @IDCho char(15), @IDNV int, @Dem int=0, @NV int, @Result int;
	fetch first from cur_1 into @IDCho, @IDNV;
	set @NV=0
	while(@@FETCH_STATUS=0)
	begin
		if(@NV not in (select distinct IDNV from NVQLCD where IDCho like concat(@Khu,'%'))) --các nhân viên quản lý khu
		begin
			set @Dem=@Dem+0;
			set @NV=@NV+1;
		end
		else if(@NV in (select distinct IDNV from NVQLCD where IDCho like concat(@Khu,'%')))
		begin
			set @Dem=@Dem+1;
			set @NV=@NV+1;
		end
		fetch next from cur_1 into @IDCho, @IDNV;
	end 
	set @Result=@Dem;
	close cur_1;
	deallocate cur_1;
	return @Result;
end
print dbo.f_SLNV('C')
--5. Hàm trả về đơn giá theo loại xe
create function f_DonGia(@LoaiXe nvarchar(10))
returns int
as begin
	declare @Tien int;
	if(@LoaiXe like N'2 bánh')
		set @Tien=2000;
	else
		set @Tien=10000
	return @Tien
end
print dbo.f_DonGia(N'4 bánh')
--7.Hàm phân loại khách tháng và khách ngày
create function f_PhanLoai(@BienSo char(15))
returns nvarchar(25)
as 
begin
	declare @LoaiKhach nvarchar(25)
	if(select count(IDKhach) from XeVao where IDKhach in (select IDKhach from KhachNgay) and BienSo=@BienSo group by BienSo) >0
		set @LoaiKhach=N'Khách ngày'
	else if(select count(IDKhach) from XeVao where IDKhach in (select IDKhach from KhachThang) and BienSo=@BienSo group by BienSo) >0
		set @LoaiKhach=N'Khách tháng'
	else set @LoaiKhach=N'Biển số không tồn tại'
	return @LoaiKhach
end
print dbo.f_PhanLoai('29K5-9521')
--VIEW--
--1. View trả về thông tin nhân viên có thời gian làm việc trên 2 năm
create view v_NV2Nam
as
	select IDNV,Ten, Ngaysinh,GioiTinh,QueQuan,ViTriLam
	from NhanVien
	where YEAR(GETDATE()) - YEAR(NgayBatDau) >= 2 
select * from v_NV2Nam
--2.View chi tiết thông tin ra vào của các khách hàng(IDKhach, BienSo, GioVao, GioRa, LoaiXe, IDCho,IDKhu LoaiKhach, NVQLKhach, NVQLIDCho)
create view v_TTKH
as
	select XeVao.IDKhach, XeVao.BienSo, XeVao.GioVao, PhuongTien.GioRa, PhuongTien.LoaiXe, PhuongTien.IDCho,
	SUBSTRING(PhuongTien.IDCho,1,1) as IDKhu,dbo.f_PhanLoai(XeVao.BienSo) as LoaiKhach,XeVao.IDNV as NVQLKhach, count(NVQLCD.IDNV) as SLNVQLCD
	from XeVao, PhuongTien, NVQLCD
	where XeVao.BienSo=PhuongTien.BienSo and XeVao.GioVao=PhuongTien.GioVao and PhuongTien.IDCho=NVQLCD.IDCho 
	group by XeVao.IDKhach, XeVao.BienSo, XeVao.GioVao, PhuongTien.GioRa, PhuongTien.LoaiXe, PhuongTien.IDCho, XeVao.IDNV, NVQLCD.IDCho
select * from dbo.v_TTKH;
--3.View chi tiết hóa đơn 
create view v_HoaDonNgay
as
	select IDHoaDon,NgayHD,ThanhTien,BienSo,XeVao.IDKhach,GioVao,IDNV
	from KhachNgay,HoaDon,XeVao
	where KhachNgay.IDKhach = HoaDon.IDKhach and HoaDon.IDKhach = XeVao.IDKhach
select * from dbo.v_HoaDonNgay
--4. View trả về thông tin chi tiết của lịch sử khách tháng
(IDTaiKhoan, TenDangNhap, Pass, HoTen, NgaySinh, SDT, GioiTinh, PhiGuiXE, BienSoKT,MaVeThang,GioVao,IDNV)
alter view v_TTKhachThang
as
	select TaiKhoan.*,MaVeThang,GioVao,XeVao.IDNV
	from TaiKhoan,KhachThang,XeVao
	where TaiKhoan.IDTaiKhoan = KhachThang.IDTaiKhoan and XeVao.IDKhach = KhachThang.IDKhach 
select * from v_TTKhachThang

--TRIGGERS-
--1. Triggers tự thêm vào bảng XeVao khi thêm bản ghi mới vào bảng PhuongTien, đồng thời cập nhật Trạng thái, Đơn Giá trong bảng ChoDo.
insert into PhuongTien values('29K6-9521', '2020-11-07 06:00:00.000',null, N'2 bánh','', 'A1')
select PhuongTien.*, ChoDo.TrangThai from PhuongTien, ChoDo where PhuongTien.IDCho=ChoDo.IDCho;
alter trigger trg_NhapPT
on PhuongTien for insert
as
if (((select GioRa from inserted) is not null) or ((select DonGia from inserted)is not null))
begin
	print N'Không nhập giờ ra và Đơn giá khi insert!'
	rollback tran
end
else
begin 
	if (select TrangThai from ChoDo where IDCho=(select IDCho from inserted)) like N'Đã sử dụng'
	--Nếu trạng thái là Đã sử dụng => Không cho nhập
	begin
		print N'Chỗ đang được sử dụng!'
		rollback tran
	end
	else
	begin
		if((select TrangThai from ChoDo where IDCho=(select IDCho from inserted)) like N'Trống')
		and ((select GioVao from inserted) <= (select top 1 GioRa from PhuongTien where IDCho=(select IDCho from inserted) order by GioRa desc))
		begin
			print N'Giờ vào phải > Giờ ra của xe trước đó!'
			rollback tran
		end
		if( (select TrangThai from ChoDo where IDCho=(select IDCho from inserted)) like N'Trống')
		and (((select GioVao from inserted) > (select top 1 GioRa from PhuongTien where IDCho=(select IDCho from inserted) order by GioRa desc))
		or (select top 1 GioRa from PhuongTien where IDCho=(select IDCho from inserted) order by GioRa desc) is null)
		--Nếu chỗ đỗ chưa từng có xe đỗ
		and (select LoaiXe from inserted) like (select KieuXe from ChoDo where IDCho=(select IDCho from inserted) )
		begin
			declare @LX nvarchar(10), @BS char(15), @Gio datetime, @Slg int, @IDKhach char(15)
			select @LX=LoaiXe from inserted;
			update PhuongTien set DonGia=dbo.f_DonGia(@LX) where GioVao=(select GioVao from inserted) and BienSo=(select BienSo from inserted)
			update ChoDo set TrangThai = N'Đã sử dụng' where IDCho=(select IDCho from inserted)
			select @BS= BienSo from inserted
			select @Gio = GioVao from inserted
			select @Slg= (select cast(SUBSTRING((select top 1 IDKhach from XeVao order by iDKhach desc),3,3) as int));
			if(len(@Slg+1)=1)
				set @IDKhach= concat('KH0',@Slg+1)
			else if((len(@Slg+1) is null))
			--Thêm bản ghi lần đầu tiên
				set @IDKhach= 'KH0'
			else
				set @IDKhach= concat('KH',@Slg+1)
			insert into XeVao(BienSo,IDKhach,GioVao) values(@BS,@IDKhach,@Gio)
			if(@BS in(select BienSoKT from TaiKhoan))
			begin
				declare @IDTK char(15), @MVT char(15);
				select @IDTK=IDTaiKhoan from TaiKhoan where BienSoKT=@BS
				set @MVT=CONCAT('000',@IDTK)
				insert into KhachThang values(@IDKhach,@IDTK,@MVT)
			end
			else 
			begin
				declare @MV char(15), @SlgV int, @idhd char(10),@slhd int;
				select @Slgv=(select cast(SUBSTRING((select top 1 MaVeNgay from KhachNgay order by MaVeNgay desc),4,2) as int));
				if(len(@Slgv+1)=1)
					set @MV=CONCAT('KHN0',@Slgv+1)
				else if((len(@Slgv+1) is null))
					set @MV= 'KHN0'
				else
					set @MV=CONCAT('KHN',@Slgv+1)
				select @slhd = (select cast(SUBSTRING((select top 1 IDHoaDon from HoaDon order by IDHoaDon desc),3,2) as int));
				if(len(@slhd+1)=1)
					set @idhd=CONCAT('HD0',@slhd+1)
				else if((len(@slhd+1) is null))
					set @idhd= 'HD0'
				else
					set @idhd=CONCAT('HD',@slhd+1)
				insert into KhachNgay values(@IDKhach,@MV);
				insert into HoaDon(IDHoaDon,IDKhach) values (@idhd,@IDKhach)
			end
			print N'Cập nhật thành công'
		end
		else
		begin
			print N'Nhập sai dữ liệu, vui lòng kiểm tra lại!'
			rollback tran
		end
	end
end
select * from PhuongTien
--2. Cập nhật Thành tiền,NgayHD cho bảng Hóa đơn khi Giờ ra được cập nhật ở bảng Phương tiện.
create trigger trg_Thanhtien
on PhuongTien for update
as
 if ((select Giora from inserted) is not null)
 begin
 update ChoDo set TrangThai = N'Trống' where IDCho =(select IDCho from inserted)
 if ((select idkhach from XeVao where BienSo =(select BienSo from inserted)and GioVao = (select GioVao from inserted)) in
	(select idkhach from KhachNgay)) --nếu idkhach là khách ngày.
 begin
	declare @giovao datetime, @giora datetime
	select @giovao = (select GioVao from PhuongTien where BienSo = (select BienSo from inserted) 
													and GioVao = (select GioVao from inserted) )
	select @giora = (select GioRa from PhuongTien where BienSo = (select BienSo from inserted) 
													and GioVao = (select GioVao from inserted))
	update HoaDon 
	set ThanhTien =(select (cast(dongia as float)/60) from PhuongTien 
	where BienSo = (select BienSo from inserted)and GioVao = (select GioVao from inserted)) * (DATEDIFF(minute,@giovao, @giora)),
							NgayHD=(select GioRa from inserted)
		where IDKhach = (select idkhach from XeVao where BienSo =(select BienSo from inserted)and GioVao = (select GioVao from inserted))
 end
 if ((select idkhach from XeVao where BienSo =(select BienSo from inserted)and GioVao = (select GioVao from inserted))
	  in (select idkhach from KhachThang)) --nếu idkhach là khách tháng.
	  print N'Đây là khách gửi theo tháng. Đã đóng tiền theo tháng.'
 end
 select * from HoaDon;
update PhuongTien set GioRa = '2020-11-04 18:00:00.000' where BienSo = '29K5-9521' and GioVao = '2020-10-11 09:00:00.000'
update PhuongTien set GioRa = '2020-10-09 20:30:00.000' where BienSo = '19G8-4561' and GioVao = '2020-11-08 08:00:00.000'
update PhuongTien set GioRa = '2020-10-11 09:00:00.000' where BienSo = '29M1-34565' and GioVao = '2020-10-10 14:30:00.000'
update PhuongTien set GioRa = '2020-10-10 18:30:00.000' where BienSo = '29M2-2223' and GioVao = '2020-10-11 20:00:00.000'
update PhuongTien set GioRa = '2020-10-11 10:30:00.000' where BienSo = '29M5-35526' and GioVao = '2020-10-11 07:00:00.000'
update PhuongTien set GioRa = '2020-10-11 18:00:00.000' where BienSo = '29U9-9024' and GioVao = '2020-10-12 10:00:00.000'
update PhuongTien set GioRa = '2020-10-11 17:00:00.000' where BienSo = '30C7-4531' and GioVao = '2020-10-11 16:30:00.000'
update PhuongTien set GioRa = '2020-10-11 18:00:00.000' where BienSo = '35J5-4652' and GioVao = '2020-10-11 15:15:00.000'
update PhuongTien set GioRa = '2020-10-11 17:30:00.000' where BienSo = '30H5-9221' and GioVao = '2020-10-10 16:00:00.000'
update PhuongTien set GioRa = '2020-10-12 01:00:00.000' where BienSo = '30Q5-2421' and GioVao = '2020-10-11 08:00:00.000'


 select datename(dw,'2020-10-12 09:00:00.000');
 select * from HoaDon;
 select * from HoaDon, XeVao where HoaDon.IDKhach=XeVao.IDKhach
 --3. Tự tính lương nhân viên khi thêm, sửa thông tin Nhân viên.
create trigger trg_LuongNV
on NhanVien for insert,update
as
if (select SoNgayLam from inserted) < 32 and (select SoNgayLam from inserted) > 0
	update NhanVien set LuongThang = dbo.f_LuongNV((select IDNV from inserted))
	where IDNV = (select IDNV from inserted)
else print N'Nhập sai dữ liệu.'

update NhanVien set SoNgayLam =30  where IDNV = 1
update NhanVien set SoNgayLam =30  where IDNV = 2
update NhanVien set SoNgayLam =28  where IDNV = 3
update NhanVien set SoNgayLam =29  where IDNV = 4
update NhanVien set SoNgayLam =29  where IDNV = 5
update NhanVien set SoNgayLam =29  where IDNV = 6
update NhanVien set SoNgayLam =29  where IDNV = 7
select * from NhanVien

--PROCEDURE--
--1. Thủ tục tìm kiếm xe theo biển số:
create proc sp_TTPhuongTien @BienSo varchar(20)
as begin
	select PhuongTien.GioVao,GioRa,LoaiXe,DonGia,PhuongTien.IDCho,XeVao.IDKhach
	from PhuongTien, XeVao
	where PhuongTien.BienSo = @BienSo and PhuongTien.BienSo = XeVao.BienSo
end
exec sp_TTPhuongTien '15H2-2321'
--2. Thủ tục giảm phí gửi xe cho khách hàng thân thiết:
create view v_SoLanGui
as
select p.*,r.IDKhach,r.IDNV from PhuongTien p, XeVao r where p.BienSo = r.BienSo and p.GioVao = r.GioVao
--lấy ra thông tin của khách hàng kèm theo biển số và idkhach.
create proc sp_GiamGia
@thang int
as begin
update TaiKhoan set PhiGuiXe = PhiGuiXe - PhiGuiXe*0.05 where BienSoKT 
in (select bienso from dbo.v_SoLanGui where DATEPART(MM,GioVao)=@thang group by bienso
	   having  COUNT(idKhach)>=all(select COUNT(idKhach)from dbo.v_SoLanGui group by bienso )) 
end
exec sp_GiamGia '11'
select * from PhuongTien;
--3. Thủ tục thống kê và in ra số tiền thu được theo ngày trong tuần:
alter proc sp_ThongKe
as begin
	declare cur_TK cursor
	scroll
	for
	select NgayHD, ThanhTien from HoaDon
	open cur_TK
	declare @ThuTrongTuan datetime,@CN money ,@Tien money, @Thu2 money, @Thu3 money, @Thu4 money, @Thu5 money, @Thu6 money, @Thu7 money;
	set @Thu2=0; set @Thu3=0; set @Thu4=0; set @Thu5=0; set @Thu6=0; set @Thu7=0; set @CN=0;
	fetch first from cur_TK into @ThuTrongTuan, @Tien
	while(@@FETCH_STATUS=0)
	begin
		if(datename(dw,@ThutrongTuan)='Sunday')
			set @CN=@CN+@Tien
		if(datename(dw,@ThutrongTuan)='Monday')
			set @Thu2=@Thu2+@Tien
		if(datename(dw,@ThutrongTuan)='Tuesday')
			set @Thu3=@Thu3+@Tien
		if(datename(dw,@ThutrongTuan)='Wednesday')
			set @Thu4=@Thu4+@Tien
		if(datename(dw,@ThutrongTuan)='Thursday')
			set @Thu5=@Thu5+@Tien
		if(datename(dw,@ThutrongTuan)='Friday')
			set @Thu6=@Thu6+@Tien
		if(datename(dw,@ThutrongTuan)='Saturday')
			set @Thu7=@Thu7+@Tien
	fetch next from cur_TK into @ThuTrongTuan, @Tien
	end
	print N'Chủ nhật: ' + cast(@CN as char(20))
	print N'Thứ hai: ' + cast(@Thu2 as char(20))
	print N'Thứ ba: ' + cast(@Thu3 as char(20))
	print N'Thứ tư: ' + cast(@Thu4 as char(20))
	print N'Thứ năm: ' + cast(@Thu5 as char(20))
	print N'Thứ sáu: ' + cast(@Thu6 as char(20))
	print N'Thứ bảy: ' + cast(@Thu7 as char(0))
	close cur_TK
	deallocate cur_TK
end
exec sp_ThongKe
--4. Thủ tục nhập IDNV cho bảng XeVao dùng random: 
create proc sp_IDNV
as begin
	declare cur_NVQL cursor
scroll 
for
	select IDKhach,IDNV from XeVao
	open cur_NVQL
		declare @IDKhach char(10), @NVQL int 
		fetch first from cur_NVQL into @IDKhach,@NVQL 
		while (@@FETCH_STATUS =0)
			begin
				if(@NVQL is null)
				begin
					declare @IDNV int
					set @IDNV = FLOOR(RAND()*(5-3+1)+3)
					update XeVao set IDNV = @IDNV where IDKhach =@IDKhach 
					set @IDNV = 0
					fetch next from cur_NVQL into @IDKhach,@NVQL
				end
				else
					 fetch next from cur_NVQL into @IDKhach,@NVQL
			end
	close cur_NVQL
	deallocate cur_NVQL	
end
exec sp_IDNV
--Nếu IDNV not null -> không cho cập nhật lại
select * from XeVao;
--TRANSACTION--
--1. Chuyển khách tháng sang khách ngày.
begin tran chuyenKhachThang
if (exists (select idtaikhoan from TaiKhoan where HoTen like N'Tạ Anh Tú'))
	begin
		declare @idtk char(10)
		select @idtk = IDTaiKhoan from TaiKhoan  where HoTen like N'Tạ Anh Tú'
		delete from KhachThang where IDTaiKhoan = @idtk
		delete from TaiKhoan where HoTen like N'Tạ Anh Tú'
		print N'Thực hiện chuyển khách tháng.'
		commit tran
	end
else
	begin
		print N'Thực hiện chuyển khách tháng không thành công.'
		rollback tran
	end

--2.Giao dịch Xóa bản ghi trong bảng phương tiện
--Xóa bản ghi trong bảng phương tiện có biển số là: 
	begin tran XoaPT
	declare @Ktra nvarchar(25), @bso varchar(20)
	set @bso = '99N2-4466'
	set @Ktra=dbo.f_PhanLoai(@bso)
	if(@Ktra like N'Khách tháng')--Nếu là khách Tháng
	begin
		delete from KhachThang where IDKhach in (select IDKhach from XeVao where BienSo=@bso)
		delete from XeVao where BienSo=@bso
		if(select count(GioRa) from PhuongTien where BienSo=@bso and GioRa is null) is not null
		--Nếu phương tiện chưa ra
		begin
			update ChoDo set TrangThai=N'Trống'
			where IDCho=(select IDCho from PhuongTien where BienSo=@bso and GioRa is null)
			delete from PhuongTien where BienSo=@bso
		end
		else --Nếu xe ra rồi
		begin
			delete from PhuongTien where BienSo=@bso
		end
		print N'Thực hiện xóa thành công'
		waitfor delay '00:00:07'
		commit tran
	end
	else if(@Ktra like N'Khách ngày')--Nếu là Khách ngày
	begin
		delete from HoaDon where IDKhach in (select IDKhach from XeVao where BienSo=@bso)
		delete from KhachNgay where IDKhach in (select IDKhach from XeVao where BienSo=@bso)
		delete from XeVao where BienSo=@bso
		if(select count(GioRa) from PhuongTien where BienSo=@bso and GioRa is null) is not null
		begin
			update ChoDo set TrangThai=N'Trống' 
			where IDCho=(select IDCho from PhuongTien where BienSo=@bso and GioRa is null)
			delete from PhuongTien where BienSo=@bso
		end
		else 
		begin
			delete from PhuongTien where BienSo=@bso
		end
		print N'Thực hiện xóa thành công'
		waitfor delay '00:00:07'
		commit tran
	end
	else--Nếu biển số không tồn tại
		begin 
			print N'Thực hiện xóa không thành công.'
			waitfor delay '00:00:07'
			rollback tran
		end
--=>Lỗi: Trong khi đang delete thì đọc sai dữ liệu (Dirty Read)
begin tran 
set tran isolation level read committed
select * from PhuongTien, XeVao where PhuongTien.BienSo=XeVao.BienSo 
and PhuongTien.GioVao = XeVao.GioVao
commit tran
--3.Giao dịch thống kế theo khu có tỷ lệ đỗ nhiều nhất trong tháng 10
begin tran TyLeMax
	set tran isolation level read committed
	declare @p int, @t int, @tb float
	select @p=count(IDKhach) 
	from dbo.v_TTKH where datepart(MM,CONVERT(date,dbo.v_TTKH.GioVao)) like '10' group by IDKhu 
	having count(IDKhach)>=all(
	select count(IDKhach) from dbo.v_TTKH where datepart(MM,CONVERT(date,dbo.v_TTKH.GioVao)) like '10' group by IDKhu)
	select @t=count(IDKhach) from dbo.v_TTKH where datepart(MM,CONVERT(date,dbo.v_TTKH.GioVao)) like '10'
	set @tb=(cast(@p as float)/@t)*100
	select datepart(MM,CONVERT(date,dbo.v_TTKH.GioVao)) as Thang,@tb as MaxTyLe ,dbo.v_TTKH.IDKhu,sum(ThanhTien) as TongTien
	from dbo.v_TTKH, dbo.v_HoaDonNgay 
	where dbo.v_TTKH.IDKhach=dbo.v_HoaDonNgay.IDKhach and datepart(MM,CONVERT(date,dbo.v_TTKH.GioVao)) like '10'
	group by datepart(MM,CONVERT(date,dbo.v_TTKH.GioVao)),dbo.v_TTKH.IDKhu
	having dbo.v_TTKH.IDKhu in (
	select  IDKhu from dbo.v_TTKH where datepart(MM,CONVERT(date,dbo.v_TTKH.GioVao)) like '10' group by IDKhu 
	having count(IDKhach)>=all(
	select count(IDKhach) from dbo.v_TTKH where datepart(MM,CONVERT(date,dbo.v_TTKH.GioVao)) like '10' group by IDKhu
	))
commit tran
--=>Lỗi: Khi đang insert thì thực hiện gd thống kê => Sai kết quả của giao dịch
begin tran
insert into PhuongTien (BienSo,GioVao,LoaiXe,DonGia,IDCho)
values ('29K5-9215','2020/10/12 16:00:00',N'2 bánh','','A4')
waitfor delay '00:00:10'
commit tran

select * from dbo.v_TTKH,dbo.v_HoaDonNgay where dbo.v_TTKH.IDKhach=dbo.v_HoaDonNgay.IDKhach

--PHÂN QUYỀN:
--User quản lý Nhân viên Chỗ đỗ: Bảng NhanVien, NVQLCD, ChoDo, PhuongTien
--NhanVien	select, update
--NVQLCD	select, update, insert
--ChoDo	select, insert
--PhuongTien	select

--user NVQLNVQLKH
--NhanVien	select, update
--XeVao	select,delete
--PhuongTien	select, delete, insert, update
--KhachThang	select, delete, insert, update
--KhachNgay	select, delete
--HoaDon	select, delete
--TaiKhoan	select, delete, update, insert
--ChoDo	select, update

----USER KhachHang
--TaiKhoan	select, update
--KhachThang	select
--PhuongTien	select
--XeVao	select
--sp_TTPhuongTien	exec




select * from HoaDon, XeVao where HoaDon.IDKhach=XeVao.IDKhach
select * from dbo.v_TTKH

--Role
sp_addrole 'KhachHang'
grant select on TaiKhoan to KhachHang
sp_addrolemember 'KhachHang','test1'
sp_addrolemember 'KhachHang','KH1'
