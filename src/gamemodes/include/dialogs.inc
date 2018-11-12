public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch (dialogid)
	{
		case DIALOG_ID_REGISTER:
		{
			if (!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_ID_REGISTER, DIALOG_STYLE_INPUT, !"{ffffff}Регистрация",
				!"{FFFFFF}Эй, ты чего? Введи пароль, иначе мы попрощаемся", !"Далее", ""); // Заменить на изначальный диалог

			if (strlen(inputtext) < 6 || strlen(inputtext) > 48) return ShowPlayerDialog(playerid, DIALOG_ID_REGISTER, DIALOG_STYLE_INPUT,
				!"{ffffff}Регистрация", !"{ffffff}Русским языком сказали: от 6 до 48 символов", !"Далее", "");

			for(new i = strlen(inputtext)-1; i != -1; i--)
			{
				switch(inputtext[i])
				{
					case 'A'..'Z', 'a'..'z', '0'..'9', '-', '+', '/', '*', '=', '_', '?': continue;
					default: return ShowPlayerDialog(playerid, DIALOG_ID_REGISTER, DIALOG_STYLE_PASSWORD, "{ffffff}Регистрация",
						"{FFFFFF}Так не пойдёт. Вводи только английские буквы и цифры", "Вход", "");
				}
			}

			new query[108];
			format(query, sizeof(query), "INSERT INTO user(username,password) VALUES('%s','%s')", Player[playerid][pUsername], inputtext);
			new Cache:cache = mysql_query(conn, query);
			cache_insert_id();
			cache_delete(cache);

			EnableBoolean(Player[playerid][pFlags], pLogged);
			Player[playerid][pSkin] = 4;
			Player[playerid][pX] = 1446.0;
			Player[playerid][pY] = -2286.9;
			Player[playerid][pZ] = 13.6;
			Player[playerid][pA] = 88.0;
			SpawnPlayer(playerid);
			SendClientMessage(playerid, COLOR_SUCCESS, !"Поздравляем с успешной регистрацией. Приятной игры на нашем сервере");
			SetTimerEx("AFK", 10000, 1, "i", playerid);
		}

		case DIALOG_ID_LOGIN:
		{
			if (!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_ID_LOGIN, DIALOG_STYLE_PASSWORD, "{ffffff}Авторизация",
				!"{FFFFFF}Эй, ты чего? Введи пароль, иначе мы попрощаемся", "Вход", "");

			if (strlen(inputtext) < 6 || strlen(inputtext) > 48) return ShowPlayerDialog(playerid, DIALOG_ID_LOGIN, DIALOG_STYLE_PASSWORD,
				"{ffffff}Авторизация", !"{ffffff}Русским языком сказали: от 6 до 48 символов", "Далее", "");

			for(new i = strlen(inputtext)-1; i != -1; i--)
			{
				switch(inputtext[i])
				{
					case 'A'..'Z', 'a'..'z', '0'..'9', '-', '+', '/', '*', '=', '_', '?': continue;
					default: return ShowPlayerDialog(playerid, DIALOG_ID_LOGIN, DIALOG_STYLE_PASSWORD, "{ffffff}Авторизация",
						!"{FFFFFF}Так не пойдёт. Вводи только английские буквы и цифры", "Вход", "");
				}
			}

			new query[82];
			format(query, sizeof(query), "SELECT * FROM user WHERE id=%i AND password='%s'", Player[playerid][pID], inputtext);
			new Cache:cache = mysql_query(conn, query);

			new rows;
			cache_get_row_count(rows);

			if (rows)
			{
				format(query, sizeof(query), "SELECT * FROM ban WHERE id = %i", Player[playerid][pID]);
				new Cache:c_cache = mysql_query(conn, query);
				cache_get_row_count(rows);
				if (rows)
				{
					new expire;
					cache_get_value_name_int(0, "expire", expire);
					if (gettime()+10800 > expire)
					{
						format(query, sizeof(query), "DELETE FROM ban WHERE id = %i", Player[playerid][pID]);
						mysql_tquery(conn, query);
					}
					else
					{
						new dialog[512];
						new reason[33], date;
						cache_get_value_name(0, "reason", reason);
						cache_get_value_name_int(0, "date", date);
						new d_year, d_month, d_day, d_hour, d_minute, d_second;
						gmtime(date, d_year, d_month, d_day, d_hour, d_minute, d_second);
						new exp_year, exp_month, exp_day, exp_hour, exp_minute, exp_second;
						gmtime(expire, exp_year, exp_month, exp_day, exp_hour, exp_minute, exp_second);
						format(dialog, sizeof(dialog), "{ffffff}Ох, надо же. Этот аккаунт {ff3333}заблокирован\n\n{ffffff}\
														Причина:\t\t{"COLOR_ACCENT_EMBED"}%s{ffffff}\n\
														Дата блокировки:\t{"COLOR_ACCENT_EMBED"}%02d.%02d.%04d {ffffff}в {"COLOR_ACCENT_EMBED"}%02d:%02d{ffffff}\n\
														Дата разблокировки:\t{"COLOR_ACCENT_EMBED"}%02d.%02d.%04d {ffffff}в {"COLOR_ACCENT_EMBED"}%02d:%02d",
														reason, d_day, d_month, d_year, d_hour, d_minute, exp_day, exp_month, exp_year, exp_hour, exp_minute);
						ShowPlayerDialog(playerid, DIALOG_ID_UNUSED, DIALOG_STYLE_MSGBOX, "{ffffff}Блокировка", dialog, "Понятно", "");
						cache_delete(c_cache);
						return KickEx(playerid, 500);
					}
				}
				cache_delete(c_cache);
				cache_set_active(cache);

				new age, fraction, fstyle, pistol, spistol, deagle, mp5, shotgun, m4, ak47;
				EnableBoolean(Player[playerid][pFlags], pLogged);

				cache_get_value_name_int(0, "age", age);
				cache_get_value_name(0, "name", Player[playerid][pName], 15);
				cache_get_value_name(0, "surname", Player[playerid][pSurname], 15);

				cache_get_value_name_float(0, "health", Player[playerid][pHealth]);
				cache_get_value_name_float(0, "armour", Player[playerid][pArmour]);

				cache_get_value_name_float(0, "x", Player[playerid][pX]);
				cache_get_value_name_float(0, "y", Player[playerid][pY]);
				cache_get_value_name_float(0, "z", Player[playerid][pZ]);
				cache_get_value_name_float(0, "a", Player[playerid][pA]);
				cache_get_value_name_int(0, "interior", Player[playerid][pInterior]);
				cache_get_value_name_int(0, "world", Player[playerid][pWorld]);

				cache_get_value_name_int(0, "skin", Player[playerid][pSkin]);

				cache_get_value_name_int(0, "fraction", fraction);

				cache_get_value_name_int(0, "fstyle", fstyle);

				cache_get_value_name_int(0, "pistol", pistol);
				cache_get_value_name_int(0, "spistol", spistol);
				cache_get_value_name_int(0, "deagle", deagle);
				cache_get_value_name_int(0, "mp5", mp5);
				cache_get_value_name_int(0, "shotgun", shotgun);
				cache_get_value_name_int(0, "m4", m4);
				cache_get_value_name_int(0, "ak47", ak47);

				SetPlayerScore(playerid, age);
				SetPlayerFightingStyle(playerid, fstyle);

				SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, pistol * 10);
				SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED, spistol * 10);
				SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, deagle * 10);
				SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, mp5 * 10);
				SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, shotgun * 10);
				SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, m4 * 10);
				SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, ak47 * 10);

				new str[4], w, a;
				for (new i = 1; i < 10; i++)
				{
					if (i == 8) continue;

					format(str, 4, "w%d", i);
					cache_get_value_name_int(0, str, w);

					format(str, 4, "a%d", i);
					cache_get_value_name_int(0, str, a);

					GivePlayerWeapon(playerid, w, a);
				}

				cache_delete(cache);

				format(query, sizeof(query), "UPDATE user SET online=1 WHERE id=%i", Player[playerid][pID]);
				mysql_tquery(conn, query);

				if (IsGang(fraction))
				{
					//cache = mysql_query(conn, !"SELECT gang FROM gangzones");
					//cache_get_row_count(rows);
					//for (new i; i < total_gangzones; i++)
					//{
					//	new gang, color;
					//	cache_get_value_name_int(i, "gang", gang);
					//	switch (gang)
					//	{
					//		case FRACTION_GROVE: color = 0x00800099;
					//		case FRACTION_BALLAS: color = 0xBC2A8D99;
					//		default: color = 0xFFFFFFAA;
					//	}
					//	GangZoneShowForAll(GangZone[i][gzID], color);
					//}
					//cache_delete(cache);
					//for (new i; i < 100; i++) GangZoneShowForPlayer(playerid, i, 0x00800099);
				}

				if (!IsAdmin(playerid)) SetTimerEx("AFK", 10000, 1, "i", playerid);

				//SendClientMessage(playerid, COLOR_SUCCESS, !"С возвращением");
				GameTextForPlayer(playerid, "~w~Welcome", 1, 1);
				SpawnPlayer(playerid);
			}
			else
			{
				if (GetPVarInt(playerid, "login_attempt") > 3)
				{
					DeletePVar(playerid, "login_attempt");
					SendClientMessage(playerid, COLOR_FAIL, !"Ты много раз ввёл неправильный пароль, и я был вынужден попрощаться, прости");
					SendClientMessage(playerid, COLOR_FAIL, !"Может, ты забыл пароль? Восстанови его по адресу: {ffffff}"SERVER_WEBSITE"/recovery");
					return KickEx(playerid, 500);
				}

				SetPVarInt(playerid, "login_attempt", GetPVarInt(playerid, "login_attempt")+1);

				ShowPlayerDialog(playerid, DIALOG_ID_LOGIN, DIALOG_STYLE_PASSWORD, !"{ffffff}Авторизация",
						!"{FFFFFF}Что-то тут не так. Ты точно ввёл правильный пароль? Попробуй ещё раз\n\
						Если забыл - переходи на "SERVER_WEBSITE" и восстанавливай пароль", "Вход", "");
			}
		}

		case DIALOG_ID_HOME:
		{
			if (response)
			{
				new str[42], int, door;
				format(str, sizeof(str), "SELECT int,door FROM house WHERE id=%i", GetPVarInt(playerid, "house_id"));
				
				new Cache:cache = mysql_query(conn, str);
				cache_get_value_name_int(0, "int", int);
				cache_get_value_name_int(0, "door", door);
				cache_delete(cache);

				if (door) return Thoughts(playerid, "Чёрт! Дверь закрыта..");

				SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "house_id"));
				SetPlayerInterior(playerid, ints[int][hiInt]);
				SetPlayerPos(playerid, ints[int][hiX], ints[int][hiY], ints[int][hiZ]);
				SetPlayerFacingAngle(playerid, ints[int][hiA]);
			}
		}
	}
	return 1;
}