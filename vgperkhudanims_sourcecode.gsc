#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps/mp/zombies/_zm_perks;

init()
{
    level thread onPlayerConnect();
    replaceFunc(::give_perk, ::give_perk_override);
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	level endon("game_ended");
    for(;;)
    {
        self waittill("spawned_player");
		self iprintln("^4Vanguard Perk Animation ^7created by ^1techboy04gaming");
    }
}

perkHUD(perk)
{
	level endon("end_game");
	self endon( "disconnect" );


    switch( perk ) {
    	case "specialty_armorvest":
        	shader = "specialty_juggernaut_zombies";
        	break;
    	case "specialty_quickrevive":
        	shader = "specialty_quickrevive_zombies";
        	break;
    	case "specialty_fastreload":
        	shader = "specialty_fastreload_zombies";
        	break;
    	case "specialty_rof":
        	shader = "specialty_doubletap_zombies";
        	break;  
    	case "specialty_longersprint":
        	shader = "specialty_marathon_zombies";
        	break; 
    	case "specialty_flakjacket":
        	shader = "specialty_divetonuke_zombies";
        	break;  
    	case "specialty_deadshot":
        	shader = "specialty_ads_zombies";
        	break;
    	case "specialty_additionalprimaryweapon":
        	shader = "specialty_additionalprimaryweapon_zombies";
        	break; 
		case "specialty_scavenger": 
			shader = "specialty_tombstone_zombies";
        	break; 
    	case "specialty_finalstand":
			shader = "specialty_chugabud_zombies";
        	break; 
    	case "specialty_nomotionsensor":
			shader = "specialty_vulture_zombies";
        	break; 
    	case "specialty_grenadepulldeath":
			shader = "specialty_electric_cherry_zombie";
        	break; 
    	default:
        	shader = "";
        	break;
    }


	perk_hud = newClientHudElem(self);
	perk_hud.alignx = "center";
	perk_hud.aligny = "middle";
	perk_hud.horzalign = "user_center";
	perk_hud.vertalign = "user_top";
	perk_hud.x += 0;
	perk_hud.y += 120;
	perk_hud.fontscale = 2;
	perk_hud.alpha = 1;
	perk_hud.color = ( 1, 1, 1 );
	perk_hud.hidewheninmenu = 1;
	perk_hud.foreground = 1;
	perk_hud setShader(shader, 128, 128);
	
	
	perk_hud moveOvertime( 0.25 );
    perk_hud fadeovertime( 0.25 );
    perk_hud scaleovertime( 0.25, 64, 64);
    perk_hud.alpha = 1;
    perk_hud.setscale = 2;
    wait 3.25;
    perk_hud moveOvertime( 1 );
    perk_hud fadeovertime( 1 );
    perk_hud.alpha = 0;
    perk_hud.setscale = 5;
    perk_hud scaleovertime( 1, 128, 128);
    wait 1;
    perk_hud notify( "death" );

    if ( isdefined( perk_hud ) )
        perk_hud destroy();
}


getPerkShader(perk)
{
	if(perk == "specialty_armorvest") //Juggernog
		return "Juggernog";
	if(perk == "specialty_rof") //Doubletap
		return "Double Tap";
	if(perk == "specialty_longersprint") //Stamin Up
		return "Stamin-Up";
	if(perk == "specialty_fastreload") //Speedcola
		return "Speed Cola";
	if(perk == "specialty_additionalprimaryweapon") //Mule Kick
		return "Mule Kick";
	if(perk == "specialty_quickrevive") //Quick Revive
		return "Quick Revive";
	if(perk == "specialty_finalstand") //Whos Who
		return "Who's Who";
	if(perk == "specialty_grenadepulldeath") //Electric Cherry
		return "Electric Cherry";
	if(perk == "specialty_flakjacket") //PHD Flopper
		return "PHD Flopper";
	if(perk == "specialty_deadshot") //Deadshot
		return "Deadshot Daiquiri";
	if(perk == "specialty_scavenger") //Tombstone
		return "Tombstone";
	if(perk == "specialty_nomotionsensor") //Vulture
		return "Vulture Aid";
}

give_perk_override( perk, bought )
{
    self setperk( perk );
    self.num_perks++;

    if ( isdefined( bought ) && bought )
    {
        self maps\mp\zombies\_zm_audio::playerexert( "burp" );

        if ( isdefined( level.remove_perk_vo_delay ) && level.remove_perk_vo_delay )
            self maps\mp\zombies\_zm_audio::perk_vox( perk );
        else
            self delay_thread( 1.5, maps\mp\zombies\_zm_audio::perk_vox, perk );

        self setblur( 4, 0.1 );
        wait 0.1;
        self setblur( 0, 0.1 );
        self notify( "perk_bought", perk );
    }

    self perk_set_max_health_if_jugg( perk, 1, 0 );

    if ( !( isdefined( level.disable_deadshot_clientfield ) && level.disable_deadshot_clientfield ) )
    {
        if ( perk == "specialty_deadshot" )
            self setclientfieldtoplayer( "deadshot_perk", 1 );
        else if ( perk == "specialty_deadshot_upgrade" )
            self setclientfieldtoplayer( "deadshot_perk", 1 );
    }

    if ( perk == "specialty_scavenger" )
        self.hasperkspecialtytombstone = 1;

    players = get_players();

    if ( use_solo_revive() && perk == "specialty_quickrevive" )
    {
        self.lives = 1;

        if ( !isdefined( level.solo_lives_given ) )
            level.solo_lives_given = 0;

        if ( isdefined( level.solo_game_free_player_quickrevive ) )
            level.solo_game_free_player_quickrevive = undefined;
        else
            level.solo_lives_given++;

        if ( level.solo_lives_given >= 3 )
            flag_set( "solo_revive" );

        self thread solo_revive_buy_trigger_move( perk );
    }

    if ( perk == "specialty_finalstand" )
    {
        self.lives = 1;
        self.hasperkspecialtychugabud = 1;
        self notify( "perk_chugabud_activated" );
    }

    if ( isdefined( level._custom_perks[perk] ) && isdefined( level._custom_perks[perk].player_thread_give ) )
        self thread [[ level._custom_perks[perk].player_thread_give ]]();

    self set_perk_clientfield( perk, 1 );
    maps\mp\_demo::bookmark( "zm_player_perk", gettime(), self );
    self maps\mp\zombies\_zm_stats::increment_client_stat( "perks_drank" );
    self maps\mp\zombies\_zm_stats::increment_client_stat( perk + "_drank" );
    self maps\mp\zombies\_zm_stats::increment_player_stat( perk + "_drank" );
    self maps\mp\zombies\_zm_stats::increment_player_stat( "perks_drank" );

    if ( !isdefined( self.perk_history ) )
        self.perk_history = [];

    self.perk_history = add_to_array( self.perk_history, perk, 0 );

    if ( !isdefined( self.perks_active ) )
        self.perks_active = [];

    self.perks_active[self.perks_active.size] = perk;
    self notify( "perk_acquired" );
    self thread perk_think( perk );
    self perkHUD(perk);
}
