delete [@M_BRANCH]

insert [@M_BRANCH] (
	code ,			Name,			[U_M_Branch_TaxId],			[U_M_BUILD_NAME] ,		[U_M_ROOM_NO],
	[U_M_FLOOR_NO],	[U_M_ADD_NO],	[U_M_STREET_NAME],			[U_M_TAMBON],			[U_M_AMPHUR],
	[U_M_PROVINCE],	[U_M_POSTAL_CODE], [DocEntry]  )

values (
	'00000',		'Head office',	'0105544090661',			N'��¸�� ��������' ,		N'��ͧ 240/2,240/41' , 
	N'��� 1,20' ,	N'�Ţ��� 240' ,	N'����Ѫ�����ɡ' ,				N'�ǧ���¢�ҧ' ,			N'ࢵ���¢�ҧ' , 
	N'��ا෾��ҹ��' , N'10310', 1 )

insert [@M_BRANCH] (
	code ,			Name,			[U_M_Branch_TaxId],			[U_M_BUILD_NAME] ,		[U_M_ROOM_NO],
	[U_M_FLOOR_NO],	[U_M_ADD_NO],	[U_M_STREET_NAME],			[U_M_TAMBON],			[U_M_AMPHUR],
	[U_M_PROVINCE],	[U_M_POSTAL_CODE], [DocEntry] )

values (
	'00001',		'Rayong Branch',	'0105544090661',			N'' ,		N'' , 
	N'' ,			N'�Ţ��� 64/34 ���� 4' ,	N'' ,				N'�ӺŻ�ǡᴧ' ,			N'����ͻ�ǡᴧ' , 
	N'���ͧ' , N'21140', 2 )


