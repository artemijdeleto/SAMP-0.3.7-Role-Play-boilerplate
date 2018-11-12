CMD:time(playerid, params[])
{
	new time[32];
	new h, m, s, y, mo, d;
	new const month[13][] = {
		"",
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December"
	};
	// i think it's not important to keep date in format dd/mm, may be we should use only hh:mm:ss?

	gettime(h, m, s);
	getdate(y, mo, d);
	format(time, sizeof(time), "~w~%s%d:%s%d:%s%d~n~%s%d %s",
		(h < 10) ? ("0") : (""), h, (m < 10) ? ("0") : (""), m, (s < 10) ? ("0") : (""), s, ((d < 10) ? ("0") : ("")), d, month[mo]);
	GameTextForPlayer(playerid, time, 999, 1); // replace with textdraw
	return 1;
}

CMD:sms(playerid, params[])
{
	new Cache:c, q[80];
	format(q, sizeof(q), "SELECT phone,cash FROM phone WHERE id=%i", Player[playerid][pID]);
	c = mysql_query(conn, q);
	if (cache_num_rows())
	{
		new phone, cash;
		cache_get_value_name_int(0, "phone", phone);
		cache_get_value_name_int(0, "cash", cash);
		cache_delete(c);
		if (cash < 5) return Error(playerid, "На вашем счёте недостаточно средств. Пополните баланс в ближайшем аппарате");

		if (sscanf(params, "is[101]", params[0], params[1])) return Usage(playerid, "/sms [номер] [сообщение]");

		format(q, sizeof(q), "SELECT id FROM phone WHERE number=%i", params[0]);
		c = mysql_query(conn, q);
		if (cache_num_rows())
		{
			format(q, sizeof(q), "UPDATE phone SET cash=cash-5 WHERE id=%i", Player[playerid][pID]);
			mysql_tquery(conn, q);
			format(q, sizeof(q), "SELECT id,online FROM user WHERE id=(SELECT id FROM phone WHERE number=%i)", params[0]);
			c = mysql_query(conn, q);
			new id,online;
			cache_get_value_name_int(0, "id", id);
			cache_get_value_name_int(0, "online", online);
			cache_delete(c);
			if (online)
			{
				foreach (Player, i)
				{
					if (Player[i][pID] == id)
					{
						new msg[144];
						format(msg, sizeof(msg), "[SMS] %s. От: %i", params[1], phone);
						SendClientMessage(i, COLOR_SMS, msg);
						format(msg, sizeof(msg), "[SMS] %s. Кому: %i", params[1], params[0]);
						SendClientMessage(playerid, COLOR_SMS, msg);
						break;
					}
				}
			}

			else
			{
				mysql_format(conn, q, sizeof(q), "INSERT INTO sms(`to`,`from`,text,date) VALUES(%i,%i,'%e',%i)", params[0], phone, params[1], gettime()+10800);
				mysql_tquery(conn, q);
				SendClientMessage(playerid, COLOR_ERROR, "Абонент недоступен или находится вне зоны действия сети. Он увидит ваше сообщение, как только появится в сети");
			}
		}

		else Error(playerid, "Набранный номер не существует или набран неправильно. Попробуйте ещё раз");
	}

	else Thoughts(playerid, "Жаль, что у меня нет телефона. Сейчас бы мог отправить сообщение");

	cache_delete(c);

	return 1;
}

CMD:ml(playerid, params[])
{
	if (IsAdmin(playerid) > 5)
	{
		if (sscanf(params, "ii", params[0], params[1])) return Usage(playerid, "/ml [ID] [организация]");
		new rank;
		switch (params[1])
		{
			case FRACTION_MAYOR: rank = 5;
			case FRACTION_LSPD..FRACTION_LVPD: rank = 8;
			default: rank = 7;
		}
		new q[64];
		format(q, sizeof(q), "UPDATE user SET fraction=%i,rank=%i WHERE id=%i", params[1], rank, Player[params[0]][pID]);
		mysql_query(conn, q, false);
		SetPlayerFractionSkin(playerid);
		SetPlayerFractionColor(playerid);
		//SendClientMessage(params[0], COLOR_SUCCESS, "Поздравляем");
	}
	return 1;
}

CMD:lock(playerid)
{
	if (IsPlayerInAnyVehicle(playerid))
	{
		ToggleVehicleDoors(GetPlayerVehicleID(playerid));
	}

	else
	{
		new Float:x, Float:y, Float:z;
		for (new i; i < MAX_VEHICLES; i++)
		{
			GetVehiclePos(i, x, y, z);
			if (IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z))
			{
				new Cache:c, q[48];
				format(q, sizeof(q), "SELECT id FROM car WHERE id=%i AND pid=%i", Vehicle[i][vID], Player[playerid][pID]);
				c = mysql_query(conn, q);
				if (cache_num_rows())
				{
					ToggleVehicleDoors(GetPlayerVehicleID(playerid));
					cache_delete(c);
					break;
				}
				cache_delete(c);
			}
		}
	}
	return 1;
}

CMD:cmd(playerid, params[])
{
	if (IsAdmin(playerid) > 6)
	{
		if (sscanf(params, "is[32]s[128]", params[0], params[1], params[2])) return Usage(playerid, "/cmd [ID] [команда] [параметры]");

		new func[32];
		format(func, sizeof(func), "cmd_%s", params[1]);
		CallRemoteFunction(func, "is", params[0], params[2]);
	}
	return 1;
}

CMD:r(playerid, params[])
{
	new f = GetPlayerData(Player[playerid][pID], "fraction");
	if (FRACTION_MAYOR <= f && f <= FRACTION_LVPD)
	{
		if (/*sscanf(params, "s[80]", params[0])*/!strlen(params) || strfind(params[0], " ") > -1) return Usage(playerid, "/r [сообщение]");
		new msg[144];
		format(msg, sizeof(msg), "[R] %s {ffffff}%c. %s{"COLOR_RADIO_EMBED"}: %s", GetPlayerRankName(playerid), Player[playerid][pName], Player[playerid][pSurname], params/*[0]*/);
		foreach (Player, i)
		{
			if (GetPlayerData(Player[i][pID], "fraction") == f)
			{
				SendClientMessage(playerid, COLOR_RADIO, msg);
			}
		}
	}
	return 1;
}

CMD:carpanel(playerid, params[])
{
	// find my car
	return 1;
}

CMD:skin(playerid, params[])
{
	sscanf(params, "i", params[0]);
	return SetPlayerSkin(playerid, params[0]);
}

CMD:czone(playerid, params[])
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if (GetPVarInt(playerid, "finish"))
	{
		new query[128];
		format(query, sizeof(query), "INSERT INTO gangzone(minx,miny,maxx,maxy) VALUES(%f,%f,%f,%f)", GetPVarFloat(playerid, "minx"), GetPVarFloat(playerid, "miny"), x, y);
		mysql_tquery(conn, query);
		mysql_tquery(conn, "SELECT * FROM gangzone", "LoadGangZone");
		DeletePVar(playerid, "finish");
	}
	else
	{
		SetPVarFloat(playerid, "minx", x);
		SetPVarFloat(playerid, "miny", y);
		SetPVarInt(playerid, "finish", 1);
	}
	return 1;
}

CMD:capture(playerid/*, params[]*/)
{
	new f = GetPlayerData(Player[playerid][pID], "fraction");
	if (IsGang(f))
	{
		if (GetPlayerData(Player[playerid][pID], "rank") > 5)
		{
			new h, m;
			gettime(h, m);
			if (m == 0)
			{
				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);
				new query[128];
				format(query, sizeof(query), "SELECT id, gang FROM gangzones WHERE minx <= %.3f AND %.3f <= maxx AND miny <= %.3f AND %.3f <= maxy", x, x, y, y);
				new Cache:c = mysql_query(conn, query);
				new rows;
				cache_get_row_count(rows);
				if (rows)
				{
					new id, gang;
					cache_get_value_name_int(0, "id", id);
					cache_get_value_name_int(0, "gang", gang);
					cache_delete(c);
					if (gang == f) return SendClientMessage(playerid, COLOR_THOUGHTS, !"[Мысли] Кажется, я что-то перепутал. Разве можно захватить свою же территорию?");
					GangZoneFlashForAll(GangZone[id][gzID], 0xFF0000FF);
					//GangZone[id][gzStatus] = 1;
					//GangZone[id][gzStart] = gettime();
					//or store it in mysql?
					foreach (Player, i)
					{
						new fr = GetPlayerData(Player[i][pID], "fraction");
						if (fr == gang) SendClientMessage(i, COLOR_WARNING, !"На вашу территорию напали");
						else if (fr == f) SendClientMessage(i, COLOR_SUCCESS, !"Ваша банда напала на территорию");
					}
				}
				else SendClientMessage(playerid, COLOR_THOUGHTS, !"[Мысли] А что я собрался захватывать?");
			}
			else SendClientMessage(playerid, COLOR_THOUGHTS, !"[Мысли] Ещё не время..");
		}
		else SendClientMessage(playerid, COLOR_THOUGHTS, !"[Мысли] Ах, жаль, что я не могу этого сделать");
	}
	return 1;
}

IsLeader(playerid)
{
	new q[48], f, r;
	format(q, sizeof(q), "SELECT fraction,rank FROM user WHERE id=%i", Player[playerid][pID]);
	mysql_query(conn, q);
	cache_get_value_name_int(0, "fraction", f);
	cache_get_value_name_int(0, "rank", r);
	if (
		(FRACTION_LSPD <= f && f <= FRACTION_LVPD && r == 8) ||
		(FRACTION_GROVE <= f && f <= FRACTION_RUSSIANMAFIA && r == 7)
		) return 1;
	return 0;
}

CMD:invite(playerid, params[])
{
	if (IsLeader(playerid))
	{
		if (sscanf(params, "i", params[0])) return Usage(playerid, "/invite [ID]");
		UpdatePlayerPos(playerid);
		if (!IsPlayerInRangeOfPoint(params[0], 10.0, Player[playerid][pX], Player[playerid][pY], Player[playerid][pZ])) return Thoughts(playerid, "Кажется, этого человека нет рядом");

		new q[64];
		format(q, sizeof(q), "UPDATE user SET fraction=%i,rank=1 WHERE id=%i", GetPlayerData(Player[playerid][pID], "fraction"), Player[params[0]][pID]);
		mysql_tquery(conn, q);

		//SetPlayerFractionColor(params[0]);
		SetPlayerFractionSkin(params[0]);// hide it
	}
	return 1;
}

CMD:fstyle(playerid, params[])
{
	sscanf(params, "i", params[0]);
	// check for style points
	SetPlayerFightingStyle(playerid, params[0]);
	return 1;
}

CMD:hc(playerid, params[])
{
	if(sscanf(params, "i", params[0])) return Usage(playerid, "/hc [class: 0 - low, 1 - middle, 2 - high, 3 - premium]");
	new query[94], Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if (params[0] > 3) params[0] = 3;
	new int = 0;
	new price;
	if (params[0] == 0) price = RandomEx(500000, 1000000, 50000);
	else if (params[0] == 1) price = RandomEx(1000000, 2500000, 50000);
	else if (params[0] == 2) price = RandomEx(2500000, 5000000, 50000);
	else price = RandomEx(5000000, 10000000, 50000);
	format(query, sizeof(query), "INSERT INTO house(x,y,z,`int`,class,price) VALUES(%.2f,%.2f,%.2f,%i,%i,%i)", x, y, z, int, params[0], price);
	mysql_tquery(conn, query);
	mysql_tquery(conn, "SELECT * FROM house", "LoadHouses");
	return 1;
}

CMD:act(playerid, params[])
{
	return ShowPlayerDialog(playerid, DIALOG_ID_ANIMATIONS, DIALOG_STYLE_LIST, "{ffffff}Выполнить действие", "Сесть\nЛечь", "{ffffff}Выбрать", "");
}

CMD:exit(playerid, params[])
{
	if (GetPlayerInterior(playerid) && GetPlayerVirtualWorld(playerid))
	{
		new q[60], int, Cache:c;
		format(q, sizeof(q), "SELECT x,y,z,`int` FROM house WHERE id=%i", GetPlayerVirtualWorld(playerid)); // можно подменить мир читами
		c = mysql_query(conn, q);
		cache_get_value_name_int(0, "int", int);
		if (IsPlayerInRangeOfPoint(playerid, 2.0, ints[int][hiX], ints[int][hiY], ints[int][hiZ]))
		{
			new Float:x, Float:y, Float:z;
			cache_get_value_name_float(0, "x", x);
			cache_get_value_name_float(0, "y", y);
			cache_get_value_name_float(0, "z", z);

			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerPos(playerid, x, y, z);
		}
		cache_delete(c);
	}
	return 1;
}

CMD:tune(playerid, params[])
{
	sscanf(params, "i", params[0]);
	return AddVehicleComponent(GetPlayerVehicleID(playerid), params[0]);
}

CMD:guns(playerid, params[])
{
	sscanf(params, "i", params[0]);
	return GivePlayerWeapon(playerid, params[0], 100);
}

CMD:cctv(playerid, params[])
{
	if (sscanf(params, "i", params[0])) return 1;
	/*new const Float:cams[1][4] = {
		{ 1480.58, -1768.38, 50.6, 0.0 }
	};*/

	// SetPlayerCameraPos(playerid, 1480.5857, -1768.3843, 50.6529);
	// SetPlayerCameraLookAt(playerid, 1480.5858, -1767.3802, 49.9580); Mayor center

	// SetPlayerCameraPos(playerid, 1544.9364, -1753.9248, 18.8181);
	// SetPlayerCameraLookAt(playerid, 1544.1371, -1753.3228, 18.7382); Mayor right

	// SetPlayerCameraPos(playerid, 1553.9700, -1651.0200, 21.2500);
	// SetPlayerCameraLookAt(playerid, 1553.3400, -1651.8000, 20.9900); LSPD

	TogglePlayerControllable(playerid, 0);
	//TogglePlayerSpectating(playerid, 1);
	SetPlayerPos(playerid, 1480.58, -1768.38, 25.0);
	SetPlayerCameraPos(playerid, 1480.58, -1768.38, 50.6);
	SetPlayerCameraLookAt(playerid, 1480.58, -1767.38, 49.9);
	return 1;
}

CMD:passport(playerid, params[])
{
	if (!GetPlayerData(Player[playerid][pID], "passport")) return SendClientMessage(playerid, COLOR_THOUGHTS, !"[Мысли] Что я собрался показывать? У меня же нет паспорта");
	if (sscanf(params, "i", params[0])) return Usage(playerid, "/passport [ID]");

	UpdatePlayerPos(playerid);
	if (!IsPlayerInRangeOfPoint(params[0], 10.0, Player[playerid][pX], Player[playerid][pY], Player[playerid][pZ])) return SendClientMessage(playerid, COLOR_THOUGHTS, "[Мысли] Кажется, этого человека нет рядом");

	new string[256], sex_string[3][] = {"-", "муж", "жен"}, sex, age, lived;
	format(string, sizeof(string), "SELECT sex,age,lived FROM user WHERE id=%i", Player[playerid][pID]);
	new Cache:cache = mysql_query(conn, string);
	cache_get_value_name_int(0, "sex", sex);
	cache_get_value_name_int(0, "age", age);
	cache_get_value_name_int(0, "lived", lived);
	cache_delete(cache);

	format(string, sizeof(string), "{ffffff}Имя:\t\t\t%s\nФамилия:\t\t%s\nПол:\t\t\t%s.\nВозраст:\t\t%i %s\nВ государстве:\t\t%i %s", Player[playerid][pName], Player[playerid][pSurname],
		sex_string[sex], age, Years(age), lived, Years(lived));
	ShowPlayerDialog(params[0], DIALOG_ID_UNUSED, DIALOG_STYLE_MSGBOX, "{ffffff}Паспорт", string, "Отдать", "");
	return 1;
}

CMD:spec(playerid, params[])
{
	if (IsAdmin(playerid))
	{
		if (sscanf(params, "i", params[0]))
		{
			if (GetPVarInt(playerid, "spectate_for") != -1)
			{
				SetPVarInt(playerid, "spectate_for", -1);
				TogglePlayerSpectating(playerid, 0);
				return 1;
			}

			return Usage(playerid, "/spec [ID]");
		}
		if (params[0] == playerid) return Error(playerid, "нельзя наблюдать за собой");
		if (!IsPlayerConnected(params[0])) return Error(playerid, "такого игрока нет");
		if (!GetBoolean(Player[params[0]][pFlags], pLogged)) return Error(playerid, "игрок не авторизован");

		TogglePlayerSpectating(playerid, 1);
		PlayerSpectatePlayer(playerid, params[0]);
		SetPlayerInterior(playerid, GetPlayerInterior(params[0]));
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(params[0]));
		SetPVarInt(playerid, "spectate_for", params[0]);
	}
	return 1;
}

CMD:label(playerid, params[])
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	/*new name[32];
	format(name, sizeof(name), "%s %s", Player[playerid][pName], Player[playerid][pSurname]);*/
	//CreateDynamic3DTextLabel"Text", 0xFFFFFFFF, x, y, z, 25.0);
	CreateDynamic3DTextLabel("Text", 0xFFFFFFFF, x, y, z, 25.0, 0);

	return 1;
}

CMD:gethere(playerid, params[])
{
	if (IsAdmin(playerid) > 1)
	{
		if (sscanf(params, "i", params[0])) return Usage(playerid, "/gethere [ID]");
		if (!IsPlayerConnected(params[0])) return Error(playerid, "такого игрока нет");
		//UpdatePlayerPos(playerid);
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		SetPlayerPos(params[0], x, y+1.0, z);
	}
	return 1;
}

CMD:goto(playerid, params[])
{
	if (IsAdmin(playerid) > 1)
	{
		if (sscanf(params, "i", params[0])) return Usage(playerid, "/goto [ID]");
		if (!IsPlayerConnected(params[0])) return Error(playerid, "такого игрока нет");
		//UpdatePlayerPos(playerid);
		new Float:x, Float:y, Float:z;
		GetPlayerPos(params[0], x, y, z);
		SetPlayerPos(playerid, x, y+1.0, z);
	}
	return 1;
}

CMD:car(playerid, params[])
{
	if (IsAdmin(playerid))
	{
		if (sscanf(params, "i", params[0])) return Usage(playerid, "/car [ID]");//SendClientMessage(playerid, COLOR_USAGE, "Используй: /car [ID]");
		UpdatePlayerPos(playerid);
		new v = CreateVehicle(params[0], Player[playerid][pX], Player[playerid][pY], Player[playerid][pZ]+1.0, Player[playerid][pA], 157, 157, 60);
		SetVehicleVirtualWorld(v, GetPlayerVirtualWorld(playerid));
		LinkVehicleToInterior(v, GetPlayerInterior(playerid));
		SetVehicleParamsEx(v, 1, 1, 0, 0, 0, 0, 0);
		SetVehicleNumberPlate(v, SERVER_GAMEMODE_NAME);
		Vehicle[v][vID] = 0;
		Vehicle[v][vEngine] = 1;
		Vehicle[v][vLights] = 1;
		Vehicle[v][vFuel] = 100;
		Vehicle[v][vHealth] = 1000;
		PutPlayerInVehicle(playerid, v, 0);
	}
	return 1;
}

CMD:a(playerid, params[])
{
	if (IsAdmin(playerid))
	{
		//if (sscanf(params, "s[100]", params[0])) return Usage(playerid, "/a [text]");
		if (!strlen(params[0])) return Usage(playerid, "/a [сообщение]");
		new txt[144];
		format(txt, sizeof(txt), "[A] {ffffff}%c. %s{"COLOR_ADMIN_EMBED"}: %s", Player[playerid][pName], Player[playerid][pSurname], params[0]);
		ToAdmins(COLOR_ADMIN, txt);
	}
	return 1;
}

CMD:gmx(playerid)
{
	SendRconCommand("gmx");
	return 1;
}

CMD:spd(playerid, params[])
{
	if (sscanf(params, "is", params[0], params[1])) return Usage(playerid, "/spd [style. msgbox = 1, input = 2, list = 3, tablist = 4, tlheaders = 5] [text]");
	new d[5] = {
		DIALOG_STYLE_MSGBOX,
		DIALOG_STYLE_INPUT,
		DIALOG_STYLE_LIST,
		DIALOG_STYLE_TABLIST,
		DIALOG_STYLE_TABLIST_HEADERS
	};
	return ShowPlayerDialog(playerid, DIALOG_ID_UNUSED, d[params[0]], "{ffffff}Предпросмотр диалога", params[1], "Готово", "Назад");
}

CMD:kick(playerid, params[])
{
	if (IsAdmin(playerid) > 1)
	{
		if (sscanf(params, "is[32]", params[0], params[1])) return Usage(playerid, "/kick [ID] [причина]");
		if (!IsPlayerConnected(params[0])) return Error(playerid, "такого игрока нет");
		if (!GetBoolean(Player[params[0]][pFlags], pLogged)) return Error(playerid, "игрок не авторизован");
		if (IsAdmin(params[0]) > IsAdmin(playerid))
		{
			SendClientMessage(params[0], COLOR_WARNING, "Кто-то хотел вас кикнуть");
			return Error(playerid, "игрок является администратором");
		}

		new msg[144];
		format(msg, sizeof(msg), "Администрация выгнала игрока {ffffff}%s {ff3333}по причине: {ffffff}%s", Player[params[0]][pUsername], params[1]);
		SendClientMessageToAll(0xFF3333FF, msg);
		KickEx(params[0], 500);
	}
	return 1;
}

CMD:skick(playerid, params[])
{
	if (IsAdmin(playerid) > 2)
	{
		if (sscanf(params, "i", params[0])) return Usage(playerid, "/skick [ID]");
		if (!IsPlayerConnected(params[0])) return Error(playerid, "такого игрока нет");
		if (!GetBoolean(Player[params[0]][pFlags], pLogged)) return Error(playerid, "игрок не авторизован");
		if (IsAdmin(params[0]) > IsAdmin(playerid))
		{
			SendClientMessage(params[0], COLOR_WARNING, "Кто-то хотел вас кикнуть");
			return Error(playerid, "игрок является администратором");
		}

		new msg[72];
		format(msg, sizeof(msg), "[A] {ffffff}%s {ff3333}тихо выгнал игрока {ffffff}%s", Player[playerid][pUsername], Player[params[0]][pUsername]);
		ToAdmins(0xFF3333FF, msg);

		ApplyAnimation(params[0], "good", "bye", 4.1, 1, 1, 1, 1, 1);
		SetPlayerAttachedObject(params[0], 0, params[0], 0);
		KickEx(params[0], 1000);
	}
	return 1;
}

CMD:ban(playerid, params[])
{
	if (IsAdmin(playerid) > 2)
	{
		if (sscanf(params, "iis[32]", params[0], params[1], params[2])) return Usage(playerid, "/ban [ID] [кол-во дней] [причина / код]");
		if (!IsPlayerConnected(params[0])) return Error(playerid, "такого игрока нет");
		if (!GetBoolean(Player[params[0]][pFlags], pLogged)) return Error(playerid, "игрок не авторизован");
		if (IsAdmin(params[0]) > IsAdmin(playerid))
		{
			SendClientMessage(params[0], COLOR_WARNING, "Кто-то хотел вас забанить");
			return Error(playerid, "игрок является администратором");
		}
		if (params[1] < 1 || params[1] > 30) params[1] = 30;

		new msg[180], p_ip[16], a_ip[16], now = gettime()+10800;

		GetPlayerIp(params[0], p_ip, sizeof(p_ip));
		GetPlayerIp(playerid, a_ip, sizeof(a_ip));

		format(msg, sizeof(msg), "INSERT INTO ban(id,`by`,reason,date,expire,playerIP,adminIP) VALUES(%i,%i,'%s',%i,%i,'%s','%s')", // sql injection check?
		Player[params[0]][pID], Player[playerid][pID], params[2], now, now + params[1]*86400, p_ip, a_ip);
		mysql_tquery(conn, msg);

		format(msg, sizeof(msg), "Администрация заблокировала аккаунт {ffffff}%s {ff3333}на {ffffff}%i %s{ff3333} по причине: {ffffff}%s", Player[params[0]][pUsername], params[1], Days(params[1]), params[2]);
		SendClientMessageToAll(0xFF3333FF, msg);

		KickEx(params[0], 500);
	}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if (!GetBoolean(Player[playerid][pFlags], pLogged)) return 0;
	if (gettime() - Player[playerid][pCMDTime] < 2) return 0;
	Player[playerid][pCMDTime] = gettime();
	return 1;
}