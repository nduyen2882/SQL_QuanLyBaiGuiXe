create database QLBaiDoXe

create table ChucVu
(
	ViTriLam nvarchar (20) primary key,
	LuongTheoNgay int
);
create table NhanVien
(
	IDNV int primary key identity (1,1),
	Ten nvarchar(30),
	Ngaysinh date,
	GioiTinh nvarchar(10) check (GioiTinh = 'Nam' or GioiTinh = N'Nữ'),
	QueQuan nvarchar(30),
	LuongThang int default 0,
	ViTriLam nvarchar(20),
	NgayBatDau date,
	SoNgayLam int,
	foreign key (ViTriLam) references ChucVu(ViTrilam)
);
create table ChoDo
(
	IDCho char (15),
	TrangThai nvarchar (15) default N'Trống',
	KieuXe nvarchar(10),
	primary key (IDCho)
);
create table NVQLCD
(
	IDCho char (15),
	IDNV int,
	primary key (IDCho,IDNV),
	foreign key (IDCho) references ChoDo(IDCho),
	foreign key (IDNV) references NhanVien(IDNV),
);
create table PhuongTien
(
	BienSo varchar (20),
	GioVao datetime,
	GioRa datetime, 
	LoaiXe nvarchar (15),
	DonGia int,
	primary key (BienSo,GioVao),
	IDCho char (15),
	foreign key (IDCho) references ChoDo (IDCho)
);
create table XeVao
(
	BienSo varchar (20),
	IDKhach char(10) primary key,
	GioVao datetime,
	IDNV int,
	foreign key (IDNV) references NhanVien (IDNV),
	foreign key (BienSo,GioVao) references PhuongTien (BienSo,GioVao),
);
create table TaiKhoan
(
	IDTaiKhoan char (10) primary key,
	TenDangNhap nvarchar (30),
	Pass char (30),
	HoTen nvarchar (30),
	NgaySinh date,
	SDT char (15),
	GioiTinh nvarchar(8) check (GioiTinh = 'Nam' or GioiTinh = N'Nữ'),
	PhiGuiXe int
);
create table KhachThang
(
	IDKhach char (10) primary key,
	IDTaiKhoan char(10),
	MaVeThang char (15),
	foreign key (IDKhach) references XeVao(IDKhach),
	foreign key (IDTaiKhoan) references TaiKhoan(IDTaiKhoan)
);
create table KhachNgay
(
	IDKhach char(10) primary key,
	MaVeNgay char (15),
	foreign key (IDKhach) references XeVao(IDKhach)
);
create table HoaDon
(
	IDHoaDon char (10) primary key,
	NgayHD datetime,
	ThanhTien float default 0,
	IDKhach char (10),
	foreign key (IDKhach) references KhachNgay(IDKhach)
); 
--Bang ChucVu
insert into ChucVu
values (N'Quản lý bãi đỗ',200000)
insert into ChucVu
values (N'Quản lý khách hàng',300000)
--Bang NhanVien
insert into NhanVien (Ten, Ngaysinh,GioiTinh,QueQuan,LuongThang,ViTriLam,NgayBatDau,SoNgayLam)
values (N'Nguyễn Minh Nghĩa','19760726','Nam',N'Ninh Bình','',N'Quản lý bãi đỗ','20180101',30)
insert into NhanVien (Ten, Ngaysinh,GioiTinh,QueQuan,LuongThang,ViTriLam,NgayBatDau,SoNgayLam)
values (N'Lê Quốc Minh','19700612','Nam',N'Hải Phòng','',N'Quản lý bãi đỗ','20200101',30)
insert into NhanVien (Ten, Ngaysinh,GioiTinh,QueQuan,LuongThang,ViTriLam,NgayBatDau,SoNgayLam)
values (N'Lê Thị Thu Thủy','19820612',N'Nữ',N'Quảng Ninh','',N'Quản lý khách hàng','20150505',28)
insert into NhanVien (Ten, Ngaysinh,GioiTinh,QueQuan,LuongThang,ViTriLam,NgayBatDau,SoNgayLam)
values (N'Nguyễn Phương Thảo','19911120',N'Nữ',N'Hà Nội','',N'Quản lý khách hàng','20160201',29)
insert into NhanVien (Ten, Ngaysinh,GioiTinh,QueQuan,LuongThang,ViTriLam,NgayBatDau,SoNgayLam)
values (N'Nguyễn Đức Vũ','19930726','Nam',N'Hà Nội','',N'Quản lý khách hàng','20200911',29)
insert into NhanVien (Ten, Ngaysinh,GioiTinh,QueQuan,LuongThang,ViTriLam,NgayBatDau,SoNgayLam)
values (N'Bùi Công Duy','19680712','Nam',N'Đà Nẵng','',N'Quản lý bãi đỗ','20131101',29)
insert into NhanVien (Ten, Ngaysinh,GioiTinh,QueQuan,LuongThang,ViTriLam,NgayBatDau,SoNgayLam)
values (N'Trần Đức Minh','19710502','Nam',N'Thanh Hóa','',N'Quản lý bãi đỗ','20131101',29)
drop table NVQLCD;
drop table HoaDon;
drop table KhachNgay;
drop table KhachThang;
drop table TaiKhoan;
drop table XeVao;
drop table NhanVien;
drop table ChucVu;
drop table PhuongTien;
drop table ChoDo;

delete from NVQLCD;
delete from HoaDon;
delete from KhachNgay;
delete from KhachThang;
delete from XeVao;
delete from PhuongTien;
delete from ChoDo;

--Bang ChoDo
insert into ChoDo(IDCho,KieuXe)
values ('A1',N'2 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('A2',N'2 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('A3',N'2 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('A4',N'2 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('B1',N'2 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('B2',N'2 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('B3',N'2 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('B4',N'2 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('C1',N'4 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('C2',N'4 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('C3',N'4 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('C4',N'4 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('D1',N'4 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('D2',N'4 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('D3',N'4 bánh')
insert into ChoDo(IDCho,KieuXe)
values ('D4',N'4 bánh')
drop trigger trg_NhapPT
--Bang PhuongTien
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('29K5-9521','2020/10/11 09:00:00',N'2 bánh','A1')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('29U9-9024','2020/10/12 10:00:00',N'2 bánh','A2')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('29M5-35526','2020/10/11 07:00:00',N'2 bánh','A3')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('31V2-1024','2020/10/11 12:00:00',N'2 bánh','A4')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('35J5-4652','2020/10/11 15:15:00',N'2 bánh','B1')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('29M2-2223','2020/10/11 20:00:00',N'2 bánh','B2')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('29M1-34565','2020/10/10 14:30:00',N'2 bánh','B3')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('30H5-9221','2020/10/10 16:00:00',N'2 bánh','B4')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('30Q5-2421','2020/10/11 08:00:00',N'4 bánh','C1')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('30C7-4531','2020/10/11 16:30:00',N'4 bánh','C2')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('19G8-4111','2020/11/08 08:00:00',N'4 bánh','C3')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('99K2-1241','2020/10/10 20:00:00',N'4 bánh','C4')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('15H2-2321','2020/10/11 16:00:00',N'4 bánh','D1')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('30L2-1234','2020/10/11 10:00:00',N'4 bánh','D2')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('99N2-4466','2020/10/11 08:00:00',N'4 bánh','D3')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('30U2-7799','2020/10/11 07:00:00',N'4 bánh','D4')
insert into PhuongTien (BienSo,GioVao,LoaiXe,IDCho)
values ('30U2-7879','2020/11/05 07:00:00',N'2 bánh','A1')


select * from PhuongTien, ChoDo where PhuongTien.IDCho=ChoDo.IDCho;

--Bang XeVao
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH1','15H2-2321','2020-10-11 16:00:00',3)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH2','29K5-9521','2020-10-11 09:00:00',3)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH3','29M1-34565','2020-10-10 14:30:00',3)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH4','29M2-2223','2020-10-11 20:00:00',3)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH5','29U9-9024','2020-10-12 10:00:00',5)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH6','30C7-4531','2020-10-11 16:30:00',5)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH7','30U2-7799','2020-10-11 07:00:00',5)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH8','31V2-1024','2020-10-11 12:00:00',5)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH9','19G8-4561','2020-10-09 18:00:00',4)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH10','29M5-35526','2020-10-11 07:00:00',4)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH11','30H5-9221','2020-10-10 16:00:00',4)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH12','30L2-1234','2020-10-11 10:00:00',4)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH13','30Q5-2421','2020-10-11 08:00:00',4)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH14','35J5-4652','2020-10-11 15:15:00',4)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH15','99K2-1241','2020-10-10 20:00:00',5)
insert into XeVao(IDKhach,BienSo,GioVao,IDNV)
values ('KH16','99N2-4466','2020-10-11 08:00:00',5)
select * from xevao
--Bang KhachThang
insert into KhachThang
values ('KH1','TK1','000TK1')
insert into KhachThang
values ('KH2','TK2','000TK2')
insert into KhachThang
values ('KH3','TK3','000TK3')
insert into KhachThang
values ('KH4','TK4','000TK4')
insert into KhachThang
values ('KH5','TK5','000TK5')
insert into KhachThang
values ('KH6','TK6','000TK6')
insert into KhachThang
values ('KH7','TK7','000TK7')
insert into KhachThang
values ('KH8','TK8','000TK8')

alter table TaiKhoan
add BienSoKT char(15)
--Bang TaiKhoan
insert into TaiKhoan
values ('TK1','Tu1602','11223344A',N'Tạ Anh Tú','20000216','0363214758','Nam',2000000,'15H2-2321')
insert into TaiKhoan
values ('TK2','Hung1105','110500B',N'Lê Dương Hùng','20000511','0364567891','Nam',100000,'29K5-9521')
insert into TaiKhoan
values ('TK3','Duyen2508','9985464C',N'Ngô Thị Duyên','20000825','0363514428',N'Nữ',100000,'29M1-34565')
insert into TaiKhoan
values ('TK4','Huy2409','31348831ab',N'Nguyễn Quang Huy','20000924','094575621','Nam',100000,'29M2-2223')
insert into TaiKhoan
values ('TK5','Hung0102','010200ab',N'Nguyễn Mạnh Hùng','20000201','039232145','Nam',100000,'29U9-9024')
insert into TaiKhoan
values ('TK6','Nhi0405','64654872gg',N'Nguyễn Thị Yến Nhi','20000504','0321456876',N'Nữ',2000000,'30C7-4531')
insert into TaiKhoan
values ('TK7','Bao1312','1312000aa',N'Ngô Quang Bảo','20001213','0566452222','Nam',2000000,'30U2-7799')
insert into TaiKhoan
values ('TK8','Yen2212','221200Y',N'Phạm Kim Yến','20001222','0698433199',N'Nữ',100000,'31V2-1024')
--Bang KhachNgay
insert into KhachNgay
values ('KH9','KHN1')
insert into KhachNgay
values ('KH10','KHN2')
insert into KhachNgay
values ('KH11','KHN3')
insert into KhachNgay
values ('KH12','KHN4')
insert into KhachNgay
values ('KH13','KHN5')
insert into KhachNgay
values ('KH14','KHN6')
insert into KhachNgay
values ('KH15','KHN7')
insert into KhachNgay
values ('KH16','KHN8')
select * from PhuongTien, XeVao where PhuongTien.BienSo=XeVao.BienSo 
and PhuongTien.GioVao = XeVao.GioVao
--Bang HoaDon
insert into HoaDon (IDHoaDon,NgayHD,IDKhach)
values ('HD1','2020-10-09 20:30:00.000','KH09')
insert into HoaDon (IDHoaDon,NgayHD,IDKhach)
values ('HD2','2020-10-11 09:00:00.000','KH10')
insert into HoaDon (IDHoaDon,NgayHD,IDKhach)
values ('HD3','2020-10-10 18:30:00.000','KH11')
insert into HoaDon (IDHoaDon,NgayHD,IDKhach)
values ('HD4','','KH12')
insert into HoaDon (IDHoaDon,NgayHD,IDKhach)
values ('HD5','2020-10-11 10:30:00.000','KH13')
insert into HoaDon (IDHoaDon,NgayHD,IDKhach)
values ('HD6','','KH14')
insert into HoaDon (IDHoaDon,NgayHD,IDKhach)
values ('HD7','','KH15')
insert into HoaDon (IDHoaDon,NgayHD,IDKhach)
values ('HD8','2020-10-11 18:00:00.000','KH16')
--Bảng NVQLCD
insert into NVQLCD
values('A1',1),('A2',1),('A3',2),('A3',1),('A4',6),('A4',7),('B3',2),('B3',1),('B1',1),('B1',7),('B4',2),
('C1',2),('C1',7),('C2',1),('C2',2),('C3',6),('C4',6),('D1',7),('D2',7),('D3',1),('D3',6),('D4',2),('D4',1)
--Thong tin cac bang
select * from ChucVu;
select * from NhanVien
select * from ChoDo
select * from PhuongTien
select * from XeVao
select * from KhachThang
select * from KhachNgay
select * from TaiKhoan
select * from HoaDon
select * from NVQLCD
select * from HoaDon, XeVao where HoaDon.IDKhach=XeVao.IDKhach
select PhuongTien.*, ChoDo.TrangThai from PhuongTien, ChoDo where PhuongTien.IDCho=ChoDo.IDCho;
select * from dbo.v_TTKH








