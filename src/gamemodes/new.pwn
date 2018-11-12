/*
	-- TODO LIST:

		-- Поворотники с помощью UpdateVehicleDamageStatus

		-- http://pro-pawn.ru/showthread.php?
		12744-MapFix-%D0%B8%D1%81%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D1%8F-%D1%82%D0%B5%D0%BA%D1%81%D1%82%D1%83%D1%80%D0%BD%D1%8B%D1%85-%D0%B1%D0%B0%D0%B3%D0%BE%D0%B2

		format(strstre, sizeof(strstre),"no mxdate: %s%d/%s%d/%s%d %s%d:%s%d:%s%d",
		((day < 10) ? ("0") : ("")), day, ((month < 10) ? ("0") : ("")), month, (year < 10) ? ("0") : (""), year,
		(hour < 10) ? ("0") : (""), hour, (min < 10) ? ("0") : (""), min, (sec < 10) ? ("0") : (""), sec);

		new time = GetTickCount()+1000;
		while(time != GetTickCount()) { }

*/

#include "include/includes.inc"
#include "include/dc_anims.inc"
#include "include/defines.inc"

enum dialogs {
	DIALOG_ID_UNUSED,
	DIALOG_ID_REGISTER,
	DIALOG_ID_LOGIN,
	DIALOG_ID_TABMENU,
	DIALOG_ID_ANIMATIONS,
	DIALOG_ID_HOME,
	DIALOG_ID_WORK
}

enum Bool:(<<= 1) {
	pIsWorking = 1,
	pLogged
}

enum pInfo {
	pID,
	pUsername[25],
	pName[15],
	pSurname[15],
	Float:pX,
	Float:pY,
	Float:pZ,
	Float:pA,
	pInterior,
	pWorld,
	Float:pHealth,
	Float:pArmour,
	pHospital,
	//pCash,
	pSkin,
	pMinutes,
	//pFraction,
	//pIsWorking,
	//pRank,
	pFSkin,
	//pLogged,
	pAFK,
	pCMDTime,
	pChatTime,
	pPickupTime,
	Bool:pFlags
}

enum hInfo {
	hID,
	// Float:hX,
	// Float:hY,
	// Float:hZ,
	hPickup,
	hIcon
}

enum hiInfo {
	hiInt,
	Float:hiX,
	Float:hiY,
	Float:hiZ,
	Float:hiA // rotation angle of player
}

new const ints[5][hiInfo] = {
	{ 1, 223.2, 1287.5, 1082.1, 0.0 }, // middle
	{ 5, 2233.75, -1114.7, 1050.8, 0.0 }, // middle
	{ 8, 2365.2, -1134.8, 1050.8, 0.0 }, // high
	{ 11, 2282.9, -1139.8, 1050.8, 0.0 }, // middle
	{ 13, 2196.0, -1203.7, 1049.0, 0.0 } // high
};

new const house_class_name[4][] = {
	"Низкий",
	"Средний",
	"Высокий",
	"Премиум"
};

new const house_builder_name[3][] = {
	"ООО \"Астра\"",
	"ООО \"Бонава\"",
	"ООО \"Абсолют\""
};

enum bInfo {
	bID,
	Float:bX,
	Float:bY,
	Float:bZ,
	bPickup,
	bIcon
}

// enum CarBool:(<<= 1) {
// 	vEngine,
// 	vLights,
// 	vDoors,
// }

enum vInfo {
	vID,
	//vOwnerID,
	vEngine,
	vLights,
	vDoors,
	//CarBool:vFlags,
	vFuel,
	Float:vHealth,
	vPlate[10],
	vNitro
}

enum gzInfo {
	gzID,
	gzStatus,
	gzStart
}

new Player[MAX_PLAYERS][pInfo], Vehicle[MAX_VEHICLES][vInfo], House[MAX_HOUSES][hInfo], Business[MAX_BUSINESSES][bInfo], GangZone[64][gzInfo],
	total_houses, total_businesses, total_cars, total_gangzones;

new Text:logo, Text:speedo_bg, Text:speedo_info,
	PlayerText:speedo_speed[MAX_PLAYERS], PlayerText:speedo_fuel[MAX_PLAYERS],
	PlayerText:speedo_health[MAX_PLAYERS], PlayerText:speedo_params[MAX_PLAYERS];

new SpeedTimer[MAX_PLAYERS];

new pickup_spawn_enter, pickup_work;

new MySQL:conn;

#include "include/functions.inc"

#if defined DEBUG_MODE
new last_tick;
#endif

public OnGameModeInit()
{
	#if defined DEBUG_MODE
	mysql_log(ALL);
	#else
	mysql_log(NONE);
	#endif
	conn = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE);
	mysql_set_charset("cp1251", conn);
	mysql_tquery(conn, "SET NAMES cp1251");

	// new year, month, day, hour, minute, second;
	// gmtime(gettime()+10800, year, month, day, hour, minute, second);
	// printf("%02d:%02d:%02d %02d.%02d.%04d", hour, minute, second, day, month, year);

	new h;
	gettime(h);
	SetWorldTime(h); // Delete it

	mysql_pquery(conn, "SELECT * FROM house", "LoadHouses");
	mysql_pquery(conn, "SELECT * FROM business", "LoadBusinesses");
	mysql_pquery(conn, "SELECT * FROM car", "LoadCars");
	//mysql_pquery(conn, "SELECT * FROM gangzones", "LoadGangZones");

	//ShowNameTags(0);
	SetNameTagDrawDistance(20.0);

	ShowPlayerMarkers(PLAYER_MARKERS_MODE_STREAMED);
	LimitPlayerMarkerRadius(50.0);

	DisableInteriorEnterExits();
	ManualVehicleEngineAndLights();
	EnableStuntBonusForAll(0);

	SendRconCommand("announce 1");
	SendRconCommand("chatlogging 0");
	SendRconCommand("hostname "SERVER_NAME);
	SendRconCommand("weburl "SERVER_WEBSITE);
	SendRconCommand("mapname "SERVER_MAPNAME);
	SendRconCommand("language "SERVER_LANGUAGE);
	SendRconCommand("gamemodetext "SERVER_GAMEMODE_NAME);
	SendRconCommand("rcon_password "SERVER_RCON_PASSWORD);

	#include "include/textdraws.inc"
	#include "include/objects.inc"

	#if defined DEBUG_MODE
	print("--- Debug mode enabled");
	last_tick = gettime();
	#endif

	SetTimer("OnGameModeUpdate", 55000, 1);

	return 1;
}

forward OnGameModeUpdate(); // Вызывается каждую минуту
public OnGameModeUpdate()
{
	#if defined DEBUG_MODE
	printf("Offset: %i seconds", gettime() - last_tick);
	last_tick = gettime();
	#endif

	for (new v; v < MAX_VEHICLES; v++)
	{
		if (Vehicle[v][vEngine])
		{
			if (Vehicle[v][vFuel] < 2)
			{
				Vehicle[v][vEngine] = 0;
				Vehicle[v][vFuel] = 0;
				SetVehicleParamsEx(v, 0, Vehicle[v][vLights], 0, Vehicle[v][vDoors], 0, 0, 0);
			}
			else Vehicle[v][vFuel]--;
		}
	}

	new h, m;
	gettime(h, m);

	if (m) // m > 0
	{
		foreach (Player, i)
		{
			if (GetBoolean(Player[i][pFlags], pLogged))
			{
				Player[i][pMinutes]++;

				if (Player[i][pMinutes] % 10 == 0)
				{
					new query[54];
					format(query, sizeof(query), "UPDATE user SET agePoints=agePoints+1 WHERE id=%i", Player[i][pID]);
					mysql_tquery(conn, query);

					new f = GetPlayerData(Player[i][pID], "fraction");
					if (!f) continue; // if player doesn't consist in any fraction
					new earnings, rank = GetPlayerData(Player[i][pID], "rank");
					switch (f)
					{
						case FRACTION_MAYOR:
						{
							switch (rank)
							{
								case 1: earnings = 1;
								case 2: earnings = 2;
								case 3: earnings = 3;
								case 4: earnings = 4;
								case 5: earnings = 5;
								case 6: earnings = 6;
								case 7: earnings = 7;
								case 8: earnings = 8;
								case 9: earnings = 9;
								case 10: earnings = 10;
							}
						}
					}
					format(query, sizeof(query), "UPDATE user SET earnings=earnings+%i WHERE id=%i", earnings, Player[i][pID]);
					mysql_tquery(conn, query);
				}
				// no code here because we have "continue"
			}
		}

		if (h == 3 && m >= 58)
		{
			// SaveAccounts();
			// SaveBusinesses();
			// SaveCars();
		}
	}
	else
	{
		SetWorldTime(h);
		SetWeather(random(20));

		foreach (Player, i)
		{
			new query[80], earnings = GetPlayerData(Player[i][pID], "earnings");

			if (earnings)
			{
				format(query, sizeof(query), "UPDATE bill SET cash=cash+%i WHERE pid=%i AND type=1", earnings, Player[i][pID]);
				// нет проверки на существование счёта => если игрок не создал его, зп будет пропадать
				mysql_tquery(conn, query);
				if (GetPlayerData(Player[i][pID], "phone") > 0)
				{
					format(query, sizeof(query), "[SMS] На счёт зачислено %i р. Отправитель: Центральный Банк", earnings);
					SendClientMessage(i, COLOR_SMS, query);
				}
			}

			new age[23];

			if (GetPlayerData(Player[i][pID], "agePoints") > 143)
			{
				format(age, sizeof(age), ",agePoints=0,age=age+1");
				SendClientMessage(i, COLOR_SUCCESS, "С Днём Рождения!");
				SetPlayerScore(i, GetPlayerData(Player[i][pID], "age"));
			}

			format(query, sizeof(query), "UPDATE user SET earnings=0,minutes=9%s WHERE id=%i", age, Player[i][pID]);
			mysql_tquery(conn, query);

			Player[i][pMinutes] = 9;
		}
	}

	return 1;
}

public OnGameModeExit()
{
	new query[128];
	for (new v; v < MAX_VEHICLES; v++)
	{
		if (!Vehicle[v][vID]) continue;
		new Float:x, Float:y, Float:z, Float:a;
		GetVehiclePos(v, x, y, z);
		GetVehicleZAngle(v, a);
		format(query, sizeof(query), "UPDATE car SET x=%.4f,y=%.4f,z=%.4f,a=%.1f,health=%.1f,fuel=%i,engine=%i,doors=%i,lights=%i WHERE id=%i",
			x, y, z, a, Vehicle[v][vHealth], Vehicle[v][vFuel], Vehicle[v][vEngine], Vehicle[v][vDoors], Vehicle[v][vLights], Vehicle[v][vID]);
		mysql_pquery(conn, query);
	}

	mysql_close(conn);
	return 1;
}

public OnPlayerConnect(playerid)
{
	DisableBoolean(Player[playerid][pFlags], pLogged);

	GetPlayerName(playerid, Player[playerid][pUsername], MAX_PLAYER_NAME);
	SetPlayerScore(playerid, 18);

	TextDrawShowForPlayer(playerid, logo);

	RemoveBuildingForPlayer(playerid, 4002, 1479.869, -1790.400, 56.023, 1.0);
	RemoveBuildingForPlayer(playerid, 4024, 1479.869, -1790.400, 56.023, 1.0);
	RemoveBuildingForPlayer(playerid, 3980, 1481.189, -1785.069, 22.382, 1.0);
	RemoveBuildingForPlayer(playerid, 4044, 1481.189, -1785.069, 22.382, 1.0);
	RemoveBuildingForPlayer(playerid, 4003, 1481.079, -1747.030, 33.523, 1.0);
	RemoveBuildingForPlayer(playerid, 1527, 1448.2344, -1755.8984, 14.5234, 1.0);

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new query[140], Float:health, Float:armour;
	UpdatePlayerPos(playerid);
	GetPlayerHealth(playerid, health);
	GetPlayerArmour(playerid, armour);
	format(query, sizeof(query), "UPDATE user SET health=%.2f,armour=%.2f,x=%.3f,y=%.3f,z=%.2f,a=%.1f,interior=%i,world=%i,online=0 WHERE id=%i", health, armour,
		Player[playerid][pX], Player[playerid][pY], Player[playerid][pZ], Player[playerid][pA], GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid), Player[playerid][pID]);
	mysql_tquery(conn, query);
	DisableBoolean(Player[playerid][pFlags], pLogged);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if (GetBoolean(Player[playerid][pFlags], pLogged)) return SpawnPlayer(playerid);
	new query[63];
	format(query, sizeof(query), "SELECT id FROM user WHERE username='%s'", Player[playerid][pUsername]);
	mysql_tquery(conn, query, "FindAccount", "i", playerid);
	return 1;
}

forward FindAccount(playerid);
public FindAccount(playerid)
{
	if (cache_num_rows())
	{
		ShowPlayerDialog(playerid, DIALOG_ID_LOGIN, DIALOG_STYLE_PASSWORD, !"{ffffff}Авторизация",
			!"{ffffff}Этот аккаунт {"COLOR_SUCCESS_EMBED"}зарегистрирован{ffffff}. Замечательно\nВведи свой пароль, чтобы продолжить игру", "Вход", "");
		cache_get_value_name_int(0, "id", Player[playerid][pID]);
	}

	else
	{
		ShowPlayerDialog(playerid, DIALOG_ID_REGISTER, DIALOG_STYLE_INPUT, !"{ffffff}Регистрация",
			!"{ffffff}Так как аккаунт {ee0000}не зарегистрирован{ffffff}, приступим к делу\n\
					 Придумай сложный пароль и введи его в поле ниже\n\n\
			Используй {"COLOR_ACCENT_EMBED"}английский {ffffff}алфавит и цифры от {"COLOR_ACCENT_EMBED"}0 {ffffff}до {"COLOR_ACCENT_EMBED"}9\n\
			{ffffff}Хочешь усложнить? Используй символы ({"COLOR_ACCENT_EMBED"}-{ffffff}, {"COLOR_ACCENT_EMBED"}_ {ffffff}и т.д.)\n{ffffff}\
			Длина пароля: от {"COLOR_ACCENT_EMBED"}6 {ffffff}до {"COLOR_ACCENT_EMBED"}48 {ffffff}символов без пробелов",
			"Готово", "");
	}

	return 1;
}

public OnPlayerSpawn(playerid)
{
	if (!GetBoolean(Player[playerid][pFlags], pLogged)) return Kick(playerid);

	SetPlayerHealth(playerid, Player[playerid][pHealth]);
	SetPlayerArmour(playerid, Player[playerid][pArmour]);

	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, GetPlayerData(Player[playerid][pID], "cash"));

	if (GetBoolean(Player[playerid][pFlags], pIsWorking)) SetPlayerFractionSkin(playerid);//SetPlayerSkin(playerid, Player[playerid][pFSkin]);
	else SetPlayerSkin(playerid, Player[playerid][pSkin]);
	SetPlayerFractionColor(playerid);

	switch (Player[playerid][pHospital])
	{
		case 0:
		{
			SetPlayerVirtualWorld(playerid, Player[playerid][pWorld]);
			SetPlayerInterior(playerid, Player[playerid][pInterior]);
			SetPlayerPos(playerid, Player[playerid][pX], Player[playerid][pY], Player[playerid][pZ]);
			SetPlayerFacingAngle(playerid, Player[playerid][pA]);
		}
		case 1:
		{
			SetPlayerVirtualWorld(playerid, Player[playerid][pWorld]);
			SetPlayerInterior(playerid, Player[playerid][pInterior]);
			SetPlayerPos(playerid, Player[playerid][pX], Player[playerid][pY], Player[playerid][pZ]);
			SetPlayerFacingAngle(playerid, Player[playerid][pA]); // FIX
		}
	}
	SetCameraBehindPlayer(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	#if defined DEBUG_MODE
	printf("OnPlayerDeath: playerid = %i, killerid = %i, reason = %i", playerid, killerid, reason);
	#endif
	Player[playerid][pHospital] = 1;
	Player[playerid][pHealth] = 1.0;
	Player[playerid][pArmour] = 0;
	for (new i; i < total_gangzones; i++)
	{
		if (GangZone[i][gzStatus] == 1)
		{
			new player_f = GetPlayerData(Player[playerid][pID], "fraction"), killer_f = GetPlayerData(Player[killerid][pID], "fraction");
			if (IsGang(player_f) && IsGang(killer_f) && player_f != killer_f)
			{
				new query[200], Float:player_pos[3], Float:killer_pos[3];
				GetPlayerPos(playerid, player_pos[0], player_pos[1], player_pos[2]);
				GetPlayerPos(killerid, killer_pos[0], killer_pos[1], killer_pos[2]);
				format(query, sizeof(query),
					"SELECT id FROM gangzones WHERE minx <= %f AND %f <= maxx AND miny <= %f AND %f <= maxy AND minx <= %f AND %f <= maxx AND miny <= %f AND %f <= maxy",
					player_pos[0], player_pos[0], player_pos[1], player_pos[1], killer_pos[0], killer_pos[0], killer_pos[1], killer_pos[1]);
				new Cache:cache = mysql_query(conn, query);
				new rows;
				cache_get_row_count(rows);
				if (rows)
				{
					//
				}
				cache_delete(cache);
			}
		}
	}
	if (killerid != INVALID_PLAYER_ID)
	{
		new msg[100], region[28];
		GetPlayer2DZone(playerid, region, 28);
		format(msg, sizeof(msg), "[R] {ffffff}Диспетчер{"COLOR_POLICE_EMBED"}: в районе {ffffff}%s {"COLOR_POLICE_EMBED"}был тяжко травмирован {ffffff}%s %s",
			region, Player[playerid][pName], Player[playerid][pSurname]);
		ToPolice(COLOR_POLICE, msg);
		// toMedics
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	if (Vehicle[vehicleid][vID] == 0) // Если машина создана админом, НО ид 0 также в том случае, если тачка создана сервером (тачка организации)
	{
		DestroyVehicle(vehicleid);
		// Обнулять ли ячейку в массиве?
	}
	if (!strlen(Vehicle[vehicleid][vPlate]))
	{
		SetVehicleNumberPlate(vehicleid, SERVER_GAMEMODE_NAME);
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if (GetBoolean(Player[playerid][pFlags], pLogged))
	{
		if (gettime() - Player[playerid][pChatTime] < 2) return 0;
		if (GetPlayerData(Player[playerid][pID], "mute")) return Error(playerid, "у вас затычка"), 0;

		new num, b, len = strlen(text);

		for(; b < len; b++)
		{
			switch(text[b])
			{
				case ' ', ' ', '\t', '\r', '\n': num++;
				default:
				{
					if(b != 0) strmid(text, text, b, len, len);
					break;
				}
			}
		}

		if (num == len) return 0;

		for(b = len-b-1; b >= 0; b--)
		{
			switch(text[b])
			{
				case ' ', ' ', '\t', '\r', '\n': continue;
				default:
				{
					text[b+1] = 0;
					break;
				}
			}
		}
		
		new lenx = strlen(text), c = len - 1, spaces;
		
		for(; c>=0; c--)
		{
			switch(text[c])
			{
				case ' ', ' ', '\t', '\r', '\n': spaces += 1;
				default :
				{
					if(spaces > 1)
					{
						memcpy(text, text[c+spaces+1], (c+2) *4, (lenx - c - spaces - 1) *4, lenx);
						len -= spaces - 1;
					}

					if(spaces > 0)
					{
						text[c+1] = ' ';
						spaces =  0;
					}
				}
			}
		}
		
		if(spaces > 1)
		{
			memcpy(text, text[c+spaces+1], (c+2) *4, (lenx - c - spaces - 1) *4, lenx);
			len -= spaces - 1;
		}
		if(spaces > 0)
		{
			text[c+1] = ' ';
		}

		text[len] = 0;

		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);

		new msg[50], msg_near[144], msg_middle[144], msg_far[144], name[20] = "Приезжий";

		format(msg, sizeof(msg), "SELECT id FROM user WHERE id=%d AND passport=1", Player[playerid][pID]);
		new Cache:cache = mysql_query(conn, msg);

		if (cache_num_rows())
		{
			format(name, sizeof(name), "%c. %s", Player[playerid][pName], Player[playerid][pSurname]);
		}
		cache_delete(cache);

		msg[0] = EOS;

		if (!strcmp(text, "xD", true) || !strcmp(text, ":D") || !strcmp(text, ";D") || !strcmp(text, ";)") || !strcmp(text, "(;") ||
			!strcmp(text, "лол", true) || !strcmp(text, "кек", true) || !strcmp(text, "ору", true))
		{
			format(msg, sizeof(msg), "%s {ffaaaa}смеётся", name);
		}

		else if (!strcmp(text, ")") || !strcmp(text, ":)") || !strcmp(text, "(:") || !strcmp(text, "c:", true) || !strcmp(text, "c;", true))
		{
			format(msg, sizeof(msg), "%s {ffaaaa}улыбается", name);
		}

		else if (!strcmp(text, "(") || !strcmp(text, ":(") || !strcmp(text, ";(") || !strcmp(text, "):") ||
			!strcmp(text, ");") || !strcmp(text, ":c", true) || !strcmp(text, ";c", true))
		{
			format(msg, sizeof(msg), "%s {ffaaaa}грустит", name);
		}

		else
		{
			format(msg_near, sizeof(msg_near), "%s [%i]: {ffffff}%s", name, playerid, text);
			format(msg_middle, sizeof(msg_middle), "%s [%i]: {dddddd}%s", name, playerid, text);
			format(msg_far, sizeof(msg_far), "%s [%i]: {aaaaaa}%s", name, playerid, text);

			if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
			{
				new anims[6][] = { !"prtial_gngtlkA", !"prtial_gngtlkB", !"prtial_gngtlkC", !"prtial_gngtlkF", !"prtial_gngtlkG", !"prtial_gngtlkH" };

				ApplyAnimation(playerid, "GANGS", anims[random(6)], 4.1, 0, 1, 1, 0, 4000, 1);
			}

			SetPlayerChatBubble(playerid, text, COLOR_USAGE/*fix*/, 20.0, 5000);
		}

		if (strlen(msg))
		{
			foreach (Player, i)
			{
				if (IsPlayerInRangeOfPoint(i, 15.0, x, y, z))
				{
					SendClientMessage(i, GetPlayerColor(playerid), msg);
				}
			}
		}

		else
		{
			foreach (Player, i)
			{
				if (IsPlayerInRangeOfPoint(i, 10.0, x, y, z))
				{
					//format(msg, sizeof(msg), "%s [%i]: {FFFFFF}%s", name, playerid, text);
					//SendClientMessage(i, GetPlayerColor(playerid), msg);
					SendClientMessage(i, GetPlayerColor(playerid), msg_near);
				}

				else if (IsPlayerInRangeOfPoint(i, 15.0, x, y, z))
				{
					//format(msg, sizeof(msg), "%s [%i]: {DDDDDD}%s", name, playerid, text);
					//SendClientMessage(i, GetPlayerColor(playerid), msg);
					SendClientMessage(i, GetPlayerColor(playerid), msg_middle);
				}

				else if (IsPlayerInRangeOfPoint(i, 20.0, x, y, z))
				{
					//format(msg, sizeof(msg), "%s [%i]: {AAAAAA}%s", name, playerid, text);
					//SendClientMessage(i, GetPlayerColor(playerid), msg);
					SendClientMessage(i, GetPlayerColor(playerid), msg_far);
				}
			}
		}

		Player[playerid][pChatTime] = gettime();
	}
	return 0;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (newstate == PLAYER_STATE_DRIVER)
	{	
		new v = GetPlayerVehicleID(playerid);
		if (IsHaveEngine(GetVehicleModel(v)))
		{
			if (!speedo_speed[playerid])
			{
				speedo_speed[playerid] = CreatePlayerTextDraw(playerid, 371.199951, 366.213256, "0 km/h");
				PlayerTextDrawLetterSize(playerid, speedo_speed[playerid], 0.357598, 1.838932);
				PlayerTextDrawAlignment(playerid, speedo_speed[playerid], 3);
				PlayerTextDrawSetShadow(playerid, speedo_speed[playerid], 1);
				PlayerTextDrawSetProportional(playerid, speedo_speed[playerid], 1);

				speedo_fuel[playerid] = CreatePlayerTextDraw(playerid, 349.099853, 383.133209, "0 L");
				PlayerTextDrawLetterSize(playerid, speedo_fuel[playerid], 0.357598, 1.838932);
				PlayerTextDrawAlignment(playerid, speedo_fuel[playerid], 3);
				PlayerTextDrawSetShadow(playerid, speedo_fuel[playerid], 1);
				PlayerTextDrawSetProportional(playerid, speedo_fuel[playerid], 1);

				speedo_health[playerid] = CreatePlayerTextDraw(playerid, 350.699951, 399.834228, "100%");
				PlayerTextDrawLetterSize(playerid, speedo_health[playerid], 0.357598, 1.838932);
				PlayerTextDrawAlignment(playerid, speedo_health[playerid], 3);
				PlayerTextDrawSetShadow(playerid, speedo_health[playerid], 1);
				PlayerTextDrawSetProportional(playerid, speedo_health[playerid], 1);

				speedo_params[playerid] = CreatePlayerTextDraw(playerid, 320.000000, 428.000000, "Engine  ~g~Doors  ~w~Lights");
				PlayerTextDrawLetterSize(playerid, speedo_params[playerid], 0.295600, 1.568889);
				PlayerTextDrawAlignment(playerid, speedo_params[playerid], 2);
				PlayerTextDrawSetShadow(playerid, speedo_params[playerid], 1);
				PlayerTextDrawSetProportional(playerid, speedo_params[playerid], 1);
			}

			TextDrawShowForPlayer(playerid, speedo_info);
			TextDrawShowForPlayer(playerid, speedo_bg);
			PlayerTextDrawShow(playerid, speedo_speed[playerid]);
			PlayerTextDrawShow(playerid, speedo_fuel[playerid]);
			PlayerTextDrawShow(playerid, speedo_health[playerid]);

			new string[32], e[10] = "Engine", d[10] = "~g~Doors", l[10] = "~w~Lights";
			if (Vehicle[v][vEngine]) format(e, sizeof(e), "~g~Engine");
			if (Vehicle[v][vDoors]) format(d, sizeof(d), "~r~Doors");
			if (Vehicle[v][vLights]) format(l, sizeof(l), "~g~Lights");
			format(string, sizeof(string), "%s  %s  %s", e, d, l);
			PlayerTextDrawSetString(playerid, speedo_params[playerid], string);
			PlayerTextDrawShow(playerid, speedo_params[playerid]);

			SpeedTimer[playerid] = SetTimerEx("Speedometer", 100, 1, "i", playerid);
		}
	}

	else if (oldstate == PLAYER_STATE_DRIVER)
	{
		if (SpeedTimer[playerid])
		{
			TextDrawHideForPlayer(playerid, speedo_bg);
			TextDrawHideForPlayer(playerid, speedo_info);
			PlayerTextDrawHide(playerid, speedo_speed[playerid]);
			PlayerTextDrawHide(playerid, speedo_fuel[playerid]);
			PlayerTextDrawHide(playerid, speedo_health[playerid]);
			PlayerTextDrawHide(playerid, speedo_params[playerid]);
			KillTimer(SpeedTimer[playerid]);
		}
		
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 0;
}

// May be use usual Pickup for non-houses/businesses?

public OnPlayerPickUpDynamicPickup(playerid, STREAMER_TAG_PICKUP pickupid)
{
	if (gettime() - Player[playerid][pPickupTime] < 5) return 1;
	Player[playerid][pPickupTime] = gettime();

	for (new i; i < total_houses; i++)
	{
		if (pickupid == House[i][hPickup])
		{
			new house_number[20], str[256], pid, class, builder, builded, price;
			format(str, sizeof(str), "SELECT pid, class, builder, builded, price FROM house WHERE id=%i", House[i][hID]);
			new Cache:cache = mysql_query(conn, str);
			cache_get_value_name_int(0, "pid", pid);
			cache_get_value_name_int(0, "class", class);
			cache_get_value_name_int(0, "builder", builder);
			cache_get_value_name_int(0, "builded", builded);
			cache_get_value_name_int(0, "price", price);
			cache_delete(cache);

			format(house_number, sizeof(house_number), "{ffffff}Дом №%i", House[i][hID]);

			if (pid) // if house owned
			{
				if (pid == Player[playerid][pID])
				{
					new int;
					format(str, sizeof(str), "SELECT int FROM house WHERE id=%i", House[i][hID]);

					cache = mysql_query(conn, str);
					cache_get_value_name_int(0, "int", int);
					cache_delete(cache);

					SetPlayerVirtualWorld(playerid, House[i][hID]);
					SetPlayerInterior(playerid, ints[int][hiInt]);
					SetPlayerPos(playerid, ints[int][hiX], ints[int][hiY], ints[int][hiZ]);
					SetPlayerFacingAngle(playerid, ints[int][hiA]);
				}

				else
				{
					format(str, sizeof(str),
						"{ffffff}Сейчас в этом доме кто-то проживает\nМожет быть, скоро он будет свободен\n\nЗастройщик:\t{"COLOR_ACCENT_EMBED"}%s\n{ffffff}Класс:\t\t{"COLOR_ACCENT_EMBED"}%s",
						house_builder_name[builder], house_class_name[class]);
					ShowPlayerDialog(playerid, DIALOG_ID_HOME, DIALOG_STYLE_MSGBOX, house_number, str, "Войти", "Назад");
				}
			}
			else
			{
				if (builder)
				{
					if ((builded >= 3 && class == 0) || (builded >= 6 && class == 1) || (builded >= 9 && class == 2) || (builded >= 12 && class > 2))
					{
						format(str, sizeof(str),
							"{ffffff}В этом доме никто не живёт\nВы можете осмотреть его\n\nЗастройщик:\t{"COLOR_ACCENT_EMBED"}%s\n{ffffff}Класс:\t\t{"COLOR_ACCENT_EMBED"}%s\n\
							{ffffff}Стоимость:\t{"COLOR_ACCENT_EMBED"}%s р.\n\n{ffffff}Желаете приобрести дом?\nПосетите офис застройщика",
							house_builder_name[builder], house_class_name[class], AddThousandsSeparators(price));
						ShowPlayerDialog(playerid, DIALOG_ID_HOME, DIALOG_STYLE_MSGBOX, house_number, str, "Смотреть", "Назад");
					}
					else
					{
						format(str, sizeof(str),
							"{ffffff}Скоро этот дом будет построен\n\nЗастройщик:\t{"COLOR_ACCENT_EMBED"}%s\n{ffffff}Класс:\t\t{"COLOR_ACCENT_EMBED"}%s\n{ffffff}Цена:\t\t{"COLOR_ACCENT_EMBED"}%s р.",
							house_builder_name[builder], house_class_name[class], AddThousandsSeparators(price));
						ShowPlayerDialog(playerid, DIALOG_ID_UNUSED, DIALOG_STYLE_MSGBOX, house_number, str, "Понятно", "");
					}
				}
				else
				{
					ShowPlayerDialog(playerid, DIALOG_ID_UNUSED, DIALOG_STYLE_MSGBOX, house_number, "{ffffff}К сожалению, этот дом никем не строится", "Понятно", "");
				}
			}

			SetPVarInt(playerid, "house_id", House[i][hID]);

			return 1;
		}
	}

	if (pickupid == pickup_spawn_enter)
	{
		
	}

	else if (pickupid == pickup_work)
	{
		ShowPlayerDialog(playerid, DIALOG_ID_WORK, DIALOG_STYLE_LIST, "{ffffff}Центр занятости", "Водитель маршрутки\nУборщик улиц", "Выбрать", "Скрыть");
	}

	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return Kick(playerid);
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (GetBoolean(Player[playerid][pFlags], pLogged))
	{
		if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			new v = GetPlayerVehicleID(playerid);
			if (!IsHaveEngine(GetVehicleModel(v))) return 1;

			if (IsPressed(KEY_SUBMISSION))
			{
				if (Vehicle[v][vHealth] <= 300)
				{
					new const thoughts[9][] = {
						!"[Мысли] Твою мать! Ну заводись же!",
						!"[Мысли] Похоже, двигатель окончательно сломался..",
						!"[Мысли] Не заводится.. Да чтоб тебя!",
						!"[Мысли] Ну отлично, двиган заглох. И что мне теперь делать?",
						!"[Мысли] Только этого не хватало! Заводись!",
						!"[Мысли] Господи, ну за что мне это?",
						!"[Мысли] Будь ты проклято, чёртово корыто",
						!"[Мысли] Не трепи мне нервы, тупая железяка",
						!"[Мысли] Если ты сейчас не поедешь, я выброшу тебя в море"
					};

					SendClientMessage(playerid, COLOR_THOUGHTS, thoughts[random(9)]);
					return 1;
				}


				new string[32], d[10] = "~g~Doors", l[10] = "~w~Lights";
				if (Vehicle[v][vDoors]) format(d, sizeof(d), "~r~Doors");
				if (Vehicle[v][vLights]) format(l, sizeof(l), "~g~Lights");

				new a, b, boot, o;
				GetVehicleParamsEx(v, a, a, a, b, b, boot, o);
				if (!Vehicle[v][vEngine])
				{
					SetVehicleParamsEx(v, 1, Vehicle[v][vLights], a, Vehicle[v][vDoors], b, boot, 0);
					Vehicle[v][vEngine] = 1;

					format(string, sizeof(string), "~g~Engine  %s  %s", d, l);
					PlayerTextDrawSetString(playerid, speedo_params[playerid], string);
				}
				else
				{
					SetVehicleParamsEx(v, 0, Vehicle[v][vLights], a, Vehicle[v][vDoors], b, boot, 0);
					Vehicle[v][vEngine] = 0;

					format(string, sizeof(string), "Engine  %s  %s", d, l);
					PlayerTextDrawSetString(playerid, speedo_params[playerid], string);
				}
			}

			else if (IsPressed(KEY_FIRE))
			{
				new string[32], e[10] = "Engine", d[10] = "~g~Doors";
				if (Vehicle[v][vEngine]) format(e, sizeof(e), "~g~Engine");
				if (Vehicle[v][vDoors]) format(d, sizeof(d), "~r~Doors");

				new a, b, boot, o;
				GetVehicleParamsEx(v, a, a, a, b, b, boot, o);
				if (!Vehicle[v][vLights])
				{
					SetVehicleParamsEx(v, Vehicle[v][vEngine], 1, a, Vehicle[v][vDoors], b, boot, 0);
					Vehicle[v][vLights] = 1;

					format(string, sizeof(string), "%s  %s  ~g~Lights", e, d);
					PlayerTextDrawSetString(playerid, speedo_params[playerid], string);
				}
				else
				{
					SetVehicleParamsEx(v, Vehicle[v][vEngine], 0, a, Vehicle[v][vDoors], b, boot, 0);
					Vehicle[v][vLights] = 0;

					format(string, sizeof(string), "%s  %s  ~w~Lights", e, d);
					PlayerTextDrawSetString(playerid, speedo_params[playerid], string);
				}
			}

			else if (IsPressed(KEY_ACTION))
			{
				new string[32], e[10] = "Engine", l[10] = "~w~Lights";
				if (Vehicle[v][vEngine]) format(e, sizeof(e), "~g~Engine");
				if (Vehicle[v][vLights]) format(l, sizeof(l), "~g~Lights");

				new a, b, boot, o;
				GetVehicleParamsEx(v, a, a, a, b, b, boot, o);
				if (!Vehicle[v][vDoors])
				{
					SetVehicleParamsEx(v, Vehicle[v][vEngine], Vehicle[v][vLights], a, 1, b, boot, 0);
					Vehicle[v][vDoors] = 1;

					format(string, sizeof(string), "%s  ~r~Doors  %s", e, l);
					PlayerTextDrawSetString(playerid, speedo_params[playerid], string);
				}
				else
				{
					SetVehicleParamsEx(v, Vehicle[v][vEngine], Vehicle[v][vLights], a, 0, b, boot, 0);
					Vehicle[v][vDoors] = 0;

					format(string, sizeof(string), "%s  ~g~Doors  %s", e, l);
					PlayerTextDrawSetString(playerid, speedo_params[playerid], string);
				}
			}

			/*else if (IsPressed(KEY_ANALOG_LEFT))
			{
				if (GetPVarInt(playerid, "turnlights") == )
				SetVehicleParamsEx(v, Vehicle[v][vEngine], 1, alarm, doors, bonnet, boot, objective)
			}

			else if (IsPressed(KEY_ANALOG_RIGHT))
			{

			}*/

			else if (newkeys == KEY_ANALOG_UP)
			{
				new a, bonnet, boot, o;
				GetVehicleParamsEx(v, a, a, a, a, bonnet, boot, o);
				if (!bonnet)
				{
					SetVehicleParamsEx(v, Vehicle[v][vEngine], Vehicle[v][vLights], a, Vehicle[v][vDoors], 1, boot, 0);
				}
				else
				{
					SetVehicleParamsEx(v, Vehicle[v][vEngine], Vehicle[v][vLights], a, Vehicle[v][vDoors], 0, boot, 0);
				}
			}

			else if (newkeys == KEY_ANALOG_DOWN)
			{
				new a, b, boot, o;
				GetVehicleParamsEx(v, a, a, a, b, b, boot, o);
				if (!boot)
				{
					SetVehicleParamsEx(v, Vehicle[v][vEngine], Vehicle[v][vLights], a, Vehicle[v][vDoors], b, 1, 0);
				}
				else
				{
					SetVehicleParamsEx(v, Vehicle[v][vEngine], Vehicle[v][vLights], a, Vehicle[v][vDoors], b, 0, 0);
				}
			}
		}
	}
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	#if defined DEBUG_MODE
	new weapon[48];
	GetWeaponName(weaponid, weapon, sizeof(weapon));
	printf("OnPlayerWeaponShot: playerid = %i, weaponid = %i (%s), hittype = %i, hitid = %i", playerid, weaponid, weapon, hittype, hitid);
	#endif
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	new weapon[48];
	GetWeaponName(weaponid, weapon, sizeof(weapon));
	#if defined DEBUG_MODE
	printf("OnPlayerTakeDamage: playerid = %i, issuerid = %i, amount = %0.2f, weaponid = %i (%s), bodypart = %i", playerid, issuerid, amount, weaponid, weapon, bodypart);
	#endif
	// check for login?

	if (amount > 10)
	{
		new pvar[48];
		format(pvar, sizeof(pvar), "%s_skill", weapon);
		SetPVarInt(issuerid, weapon, GetPVarInt(issuerid, weapon)+1);
	}

	// may be make a distance checking?

	// FIX: armour checking
	switch (weaponid)
	{
		case 0: // Fist
		{
			switch(GetPlayerData(Player[issuerid][pID], "fstyle"))
			{
				case FIGHT_STYLE_NORMAL, FIGHT_STYLE_GRABKICK: Player[playerid][pHealth] -= 2.0;
				case FIGHT_STYLE_BOXING: Player[playerid][pHealth] -= 3.0;
				case FIGHT_STYLE_KUNGFU: Player[playerid][pHealth] -= 4.0;
				case FIGHT_STYLE_KNEEHEAD: Player[playerid][pHealth] -= 5.0;
			}
		}
		case 1..3, 5..7, 15:
		{
			Player[playerid][pHealth] -= 7.5;
		}
		case 4, 8:
		{
			Player[playerid][pHealth] -= 15.0;
		}
		case 22, 23: // 9mm & silenced
		{
			switch (bodypart)
			{
				case 3, 4: // Chest and Torso (Groin)
				{
					Player[playerid][pHealth] -= 20.0;
				}
				case 5..8: // Arms and Legs
				{
					Player[playerid][pHealth] -= 10.0;
				}
				case 9: // Head
				{
					Player[playerid][pHealth] -= 30.0;
				}
			}
		}
		case 24: // deagle
		{
			switch (bodypart)
			{
				case 3, 4: // Chest and Torso (Groin)
				{
					Player[playerid][pHealth] -= 25.0;
				}
				case 5..8: // Arms and Legs
				{
					Player[playerid][pHealth] -= 10.0;
				}
				case 9: // Head
				{
					Player[playerid][pHealth] -= 50.0;
				}
			}
		}
		case 25: // shotgun
		{
			switch (bodypart)
			{
				case 3, 4: // Chest and Torso (Groin)
				{
					Player[playerid][pHealth] -= 50.0;
				}
				case 5..8: // Arms and Legs
				{
					Player[playerid][pHealth] -= 25.0;
				}
				case 9: // Head
				{
					Player[playerid][pHealth] = 0.0;
				}
			}
		}
		case 29: // mp5
		{

		}
		case 30, 31: // m4 & ak47
		{
			switch (bodypart)
			{
				case 3, 4: // Chest and Torso (Groin)
				{
					Player[playerid][pHealth] -= 25.0;
				}
				case 5..8: // Arms and Legs
				{
					Player[playerid][pHealth] -= 15.0;
				}
				case 9: // Head
				{
					Player[playerid][pHealth] -= 50.0;
				}
			}
		}
		case 33: // rifle. may be same as one of listed?
		{

		}
		case 34:
		{
			switch (bodypart)
			{
				case 3, 4: // Chest and Torso (Groin)
				{

				}
				case 5..8: // Arms and Legs
				{

				}
				case 9: // Head
				{
					Player[playerid][pHealth] = 0.0;
				}
			}
		}
	}
	SetPlayerHealth(playerid, Player[playerid][pHealth]);
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	#if defined DEBUG_MODE
	new weapon[48];
	GetWeaponName(weaponid, weapon, sizeof(weapon));
	printf("OnPlayerTakeDamage: playerid = %i, damagedid = %i, amount = %0.2f, weaponid = %i (%s), bodypart = %i", playerid, damagedid, amount, weaponid, weapon, bodypart);
	#endif
	return 1;
}

/*public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart) // Анти-ГМ
{
	new Float: vida, Float: armadura, Float: dmg;
	   
	GetPlayerArmour(damagedid, armadura);
	GetPlayerHealth(damagedid, vida);
	   
	if(armadura > 0)
	{
		if(amount > armadura)
		{
			dmg = amount - armadura;
			vida = vida - dmg;
			SetPlayerArmour(damagedid, 0.0);
			SetPlayerHealth(damagedid, vida);
			return 1;
		}
		armadura = armadura - amount;
		SetPlayerArmour(damagedid, armadura);
	}
	if(armadura < 1)
	{
		vida = vida - amount;
		SetPlayerHealth(damagedid, vida);
	}
	return 1;
}*/

public OnRconLoginAttempt(ip[], password[], success)
{
	if (!success)
	{
		foreach (Player, i)
		{
			new pip[16];
			GetPlayerIp(i, pip, sizeof(pip));
			if (!strcmp(ip, pip, true))
			{
				ApplyAnimation(i, "good", "bye", 4.1, 1, 1, 1, 1, 1);
				SetPlayerAttachedObject(i, 0, i, 0);
				KickEx(i, 500);
			}
			break;
		}
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	Player[playerid][pAFK] = 0;
	return 1;
}

#include "include/dialogs.inc"

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if (IsAdmin(playerid)) SetPlayerPosFindZ(playerid, fX, fY, fZ);
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if (IsAdmin(playerid) && playerid != clickedplayerid)
	{
		new caption[65];
		format(caption, sizeof(caption), "{ffffff}%c. %s (%s) [%i]", Player[clickedplayerid][pName], Player[clickedplayerid][pSurname], Player[clickedplayerid][pUsername], clickedplayerid);
		ShowPlayerDialog(playerid, DIALOG_ID_TABMENU, DIALOG_STYLE_LIST, caption,
			"{ffffff}Наблюдать\nПосмотреть информацию\nТелепортировать к себе\nТелепортироваться к игроку", "Выбрать", "");
	}
	return 1;
}

#include "include/commands.inc"