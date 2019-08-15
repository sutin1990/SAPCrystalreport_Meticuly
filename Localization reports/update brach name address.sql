delete [@M_BRANCH]

insert [@M_BRANCH] (
	code ,			Name,			[U_M_Branch_TaxId],			[U_M_BUILD_NAME] ,		[U_M_ROOM_NO],
	[U_M_FLOOR_NO],	[U_M_ADD_NO],	[U_M_STREET_NAME],			[U_M_TAMBON],			[U_M_AMPHUR],
	[U_M_PROVINCE],	[U_M_POSTAL_CODE], [DocEntry]  )

values (
	'00000',		'Head office',	'0105544090661',			N'อโยธยา ทาวเวอร์' ,		N'ห้อง 240/2,240/41' , 
	N'ชั้น 1,20' ,	N'เลขที่ 240' ,	N'ถนนรัชดาภิเษก' ,				N'แขวงห้วยขวาง' ,			N'เขตห้วยขวาง' , 
	N'กรุงเทพมหานคร' , N'10310', 1 )

insert [@M_BRANCH] (
	code ,			Name,			[U_M_Branch_TaxId],			[U_M_BUILD_NAME] ,		[U_M_ROOM_NO],
	[U_M_FLOOR_NO],	[U_M_ADD_NO],	[U_M_STREET_NAME],			[U_M_TAMBON],			[U_M_AMPHUR],
	[U_M_PROVINCE],	[U_M_POSTAL_CODE], [DocEntry] )

values (
	'00001',		'Rayong Branch',	'0105544090661',			N'' ,		N'' , 
	N'' ,			N'เลขที่ 64/34 หมู่ 4' ,	N'' ,				N'ตำบลปลวกแดง' ,			N'อำเภอปลวกแดง' , 
	N'ระยอง' , N'21140', 2 )


