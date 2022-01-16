//Deltarune autosplitter by Narry
//Based on Glacia's Undertale autosplitter


state("Deltarune")
{
	//static
	uint room : 				"Deltarune.exe", 0x6AC9F0;
	
	//globals
	double money : 				"Deltarune.exe", 0x48E5DC, 0x27C, 	0x488, 	0x470;
	double fight : 				"Deltarune.exe", 0x48E5DC, 0x27C, 	0x488, 	0x490;
	double plot : 				"Deltarune.exe", 0x48E5DC, 0x27C, 	0x488, 	0x500;
	double filechoice : 		"Deltarune.exe", 0x48E5DC, 0x27C, 	0x488, 	0x4D0;
	double interact : 			"Deltarune.exe", 0x48E5DC, 0x27C, 	0x28, 	0x20;
	double choicer : 			"Deltarune.exe", 0x48E5DC, 0x27C, 	0x28, 	0x40;

	//selfs - Finding reliable pointers to these values is really weird so here's a few paths that appear to cover all the test cases I found so we don't need to use a sigscan
	double jevilDance : 		"Deltarune.exe", 0x48BDEC,  0x78, 	0x60, 	0x10, 	0x10, 	0x0;
	double jevilDance2 : 		"Deltarune.exe", 0x48BDEC,  0x7C, 	0x60, 	0x10, 	0x10, 	0x0;
	
	double finalTextboxHalt : 	"Deltarune.exe", 0x48BDEC,  0x98, 	0x60, 	0x10, 	0x274, 	0x0;
	double finalTextboxHalt2 : 	"Deltarune.exe", 0x48BDEC,  0x9C, 	0x60, 	0x10, 	0x274, 	0x0;
	
}

startup
{
	// If the log directory doesn't exist, create it
	Directory.CreateDirectory("daslog");

	// Delete the oldest log
	if (File.Exists("daslog/daslog.9"))
		File.Delete("daslog/daslog.9");

	// Roll all logs over one
	for (int i=9; i>0; i--)
		if (File.Exists("daslog/daslog." + (i-1)))
			File.Move("daslog/daslog." + (i-1), "daslog/daslog." + i);

	// Set up user settings
	settings.Add("intro", true, "Light World (Intro)");
	settings.Add("darkworld", true,  "Dark World");
	settings.Add("ending", true, "Light World (End)");
	settings.Add("jevil", true, "Jevil");
	settings.Add("jevilkey", true, "Key", "jevil");
	settings.Add("jevilfight", true, "Jevil Fight", "jevil");

	settings.Add("school", true, "Exit The School", "intro");

	settings.Add("castletown", true, "Exit Castle Town", "darkworld");
	settings.Add("fields", true, "Exit the Fields", "darkworld");

	settings.Add("kroundcheckers", true,  "K-Round Checkers", "darkworld");
	settings.Add("b-kRoundCheckersStart", true,  "K-Round Start", "kroundcheckers");
	settings.Add("b-kRoundCheckersEnd", true,  "K-Round End", "kroundcheckers");
	settings.Add("checkers", true, "Exit the Checkerboard", "darkworld");

	settings.Add("p-lancerJoin", true, "Lancer Joins the Team", "darkworld");
	settings.Add("forest", true,  "Exit the Forest Maze", "darkworld");
	settings.Add("captured", true,  "Captured by Lancer", "darkworld");
	settings.Add("jailcell",   true, "Exit the Jail Cell", "darkworld");
	settings.Add("jail",   	true, "Exit the Jail", "darkworld");
	settings.Add("jailelevator",   	true, "Exit the Jail Elevator", "darkworld");

	
	settings.Add("kroundcastle", true,  "K-Round Castle", "darkworld");
	settings.Add("b-kRoundCastleStart", true,  "K-Round Start", "kroundcastle");
	settings.Add("b-kRoundCastleEnd", true,  "K-Round End", "kroundcastle");
	
	settings.Add("throne", true, "Exit the Throne Room", "darkworld");
	settings.Add("castle", true, "Exit the Castle", "darkworld");
	settings.Add("king", true,  "King Boss", "darkworld");
	settings.Add("b-kingStart", true, "King Fight Start", "king");
	settings.Add("b-kingEnd", true, "King Fight End", "king");
	settings.Add("kingroom", true, "Exit the King Fight Room", "darkworld");
	settings.Add("kingroomRalsei", true, "Exit the King Fight Room (After Ralsei Reveal)", "darkworld");
	settings.Add("roof", true, "Exit the Roof", "darkworld");

	settings.Add("dark",   true, "Exit the Dark World", "darkworld");

	settings.Add("theend",   true, "The End (Final Text Dismissed)", "ending");
	//settings.Add("theendalt",   true, "The End Alternate (Final Textbox Dismissed, 5 frames slower)", "ending");
	
	settings.Add("i-keya", true, "Key A", "jevilkey");
	settings.Add("i-keyb", true, "Key B", "jevilkey");
	settings.Add("i-keyc", true, "Key C", "jevilkey");
	settings.Add("i-key", true, "Key Repaired", "jevilkey");

	settings.Add("b-jevilStart", true, "Jevil Fight Start", "jevilfight");
	settings.Add("b-jevilEnd", true, "Jevil Fight End", "jevilfight");
	
	
	// object array structure
	vars.visited = 0;		// bool		have we triggered this split already?
	vars.maxplot = 1;		// double	maximum allowed plot, -1 if none
	vars.reqplot = 2;		// double	required exact plot, -1 if none
	vars.oldroom = 3;		// int 		required old (last frame) room, -1 if none
	vars.curroom = 4; 		// int 		required current room, -1 if none
	vars.oldfight = 5;		//int		required old fight state, -1 if none
	vars.curfight = 6;		//int		required current fight state, -1 if none
	vars.special = 7; 		// int 		required special logic function, -1 if none

	vars.goals = new Dictionary<string, object[]>() {
		// Ruins
		
		{"school",					new object[] {false,	-1,		-1,		32,		34,		-1,		-1,	-1	}},
		{"castletown",				new object[] {false,	-1,		-1,		-1,		49,		-1,		-1,	-1	}},
		{"fields",					new object[] {false,	-1,		-1,		-1,		65,		-1,		-1,	-1	}},
		{"checkers",				new object[] {false,	-1,		-1,		-1,		73,		-1,		-1,	-1	}},
		{"forest",					new object[] {false,	-1,		-1,		-1,		98,		-1,		-1,	-1	}},
		{"captured",				new object[] {false,	-1,		-1,		-1,		105,	-1,		-1,	-1	}},
		{"jailcell",				new object[] {false,	-1,		 156,	-1,		106,	-1,		-1,	-1	}},
		{"jail",					new object[] {false,	-1,		-1,		-1,		109,	-1,		-1,	-1	}},
		{"jailelevator",			new object[] {false,	-1,		-1,		-1,		114,	-1,		-1,	-1	}},
		{"throne",					new object[] {false,	-1,		-1,		-1,		127,	-1,		-1,	-1	}},
		{"castle",					new object[] {false,	-1,		-1,		-1,		128,	-1,		-1,	-1	}},
		{"kingroom",				new object[] {false,	-1,		-1,		-1,		129,	-1,		-1,	-1	}},
		{"kingroomRalsei",			new object[] {false,	-1,		 244,	-1,		129,	-1,		-1,	-1	}},
		{"roof",					new object[] {false,	-1,		-1,		-1,		130,	-1,		-1,	-1	}},
		{"dark",					new object[] {false,	-1,		-1,		-1,		33,		-1,		-1,	-1	}},
		
		//Ends on the textwriter being discarded
		{"theend",					new object[] {false,	-1,		 251,	-1,		2,		-1,		-1,	 2	}},
		//Ends on the textbox closing
		{"theendalt",				new object[] {false,	-1,		 251,	-1,		2,		-1,		-1,	 1	}},
		
		
		{"p-lancerJoin",			new object[] {false,	-1,		130,	-1,		97,		-1,		-1,	-1	}},

		//Only battle in this room so this works
		{"b-kRoundCheckersStart",	new object[] {false,	-1,		-1,		-1,		72,		0,		1,	-1	}},
		{"b-kRoundCheckersEnd",		new object[] {false,	-1,		-1,		-1,		72,		1,		0,	-1	}},
		
		//Only battle in this room so this works
		{"b-kRoundCastleStart",		new object[] {false,	-1,		-1,		-1,		125,	0,		1,	-1	}},
		{"b-kRoundCastleEnd",		new object[] {false,	-1,		-1,		-1,		125,	1,		0,	-1	}},

		//Only battle in this room so this works
		{"b-kingStart",				new object[] {false,	-1,		-1,		-1,		128,	0,		1,	-1	}},
		{"b-kingEnd",				new object[] {false,	-1,		-1,		-1,		128,	1,		0,	-1	}},

		//Only battle in this room so this works
		{"b-jevilStart",			new object[] {false,	-1,		-1,		-1,		112,	0,		1,	-1	}},
		//Uses a custom endstate detection because we want to end on pacify not on battle exit
		{"b-jevilEnd",				new object[] {false,	-1,		-1,		-1,		112,	-1,		1,	7	}},
	
			
		{"i-key",					new object[] {false,	-1,		-1,		-1,		83,		-1,		-1,	3	}},
		{"i-keya",					new object[] {false,	-1,		-1,		-1,		133,	-1,		-1,	4	}},
		{"i-keyb",					new object[] {false,	-1,		-1,		-1,		85,		-1,		-1,	5	}},
		{"i-keyc",					new object[] {false,	-1,		-1,		-1,		64,		-1,		-1,	6	}},
			
	};
}

init
{
	vars.moduleSize = modules.First().ModuleMemorySize;
	vars.module = "0.0.4b";
	vars.justStarted = true;

	vars.log = (Func<string, bool>)((message) =>
	{
		try{
		using (StreamWriter sw = File.AppendText("daslog/daslog.0"))
			sw.WriteLine(DateTime.Now.ToString("HHmmssff  ") + message);
		return true;
		}catch(Exception e){
		using (StreamWriter sw = File.AppendText("daslog/daslog.0"))
			sw.WriteLine(DateTime.Now.ToString("HHmmssff  ") + e.ToString());
			return false;
		}
		return false;
	});

	vars.reactivate =  (Func<bool>)(() =>
	{
		foreach (string goal in vars.goals.Keys)
			vars.goals[goal][vars.visited] = false;

		vars.log("ARMED  All splits have been armed");
		return true;
	});

	vars.checkKeyItems = (Func<int, bool>)((id) =>
	{
		for (int i = 0; i < 12; i++){
			
			if (new DeepPointer("Deltarune.exe", 0x49D598, 0x264, (0x1A00 + (i*0x10))).Deref<double>(game) == id){
				return true;
			}
		}
		return false;
	});
	
	vars.log("BIRTH  v" + vars.module + " - " + vars.moduleSize);
}

update
{
	current.phase = timer.CurrentPhase;

	if (vars.justStarted)
	{
		vars.justStarted = false;
	}
	else
	{
		// Did the timer just start?
		if ((current.phase == TimerPhase.Running) && (old.phase == TimerPhase.NotRunning))
		{
			vars.reactivate();

			// Log what splits have been selected
			string splitState = "";

			foreach (string goal in vars.goals.Keys)
				splitState += (settings[goal]) ? "1" : "0";

			vars.log("STATE  " + splitState);
		}

		// Did the timer just stop?
		else if ((current.phase == TimerPhase.NotRunning) && (old.phase == TimerPhase.Running))
			vars.log("PHASE  " + old.phase.ToString() + " -> " + current.phase.ToString());
	}
}

start
{
	if (old.room != current.room)
		vars.log("EVENT  r{" + old.room + "," + current.room + "}");

	// This is the starting room for a run no matter what
	if (current.room == 1)
		return true;
}

split
{
	if (old.room != current.room)
	{
		vars.log("EVENT  ROOM CHANGED");
		vars.log("EVENT  r{" + old.room + "," + current.room + "}");
		vars.log("EVENT  p{" + old.plot + "," + current.plot + "}");
		vars.log("EVENT  f{" + old.fight + "," + current.fight + "}\n");
	}
	if (old.plot != current.plot)
	{
		vars.log("EVENT  PLOT CHANGED");
		vars.log("EVENT  r{" + old.room + "," + current.room + "}");
		vars.log("EVENT  p{" + old.plot + "," + current.plot + "}");
		vars.log("EVENT  f{" + old.fight + "," + current.fight + "}\n");
	}
	if (old.fight != current.fight)
	{
		vars.log("EVENT  FIGHT CHANGED");
		vars.log("EVENT  r{" + old.room + "," + current.room + "}");
		vars.log("EVENT  p{" + old.plot + "," + current.plot + "}");
		vars.log("EVENT  f{" + old.fight + "," + current.fight + "}\n");
	}

	foreach (string goal in vars.goals.Keys)
	{
		// is this an enabled split that is armed?
		if ((settings[goal]) && (!vars.goals[goal][vars.visited]))
		{
			// is there a current room requirement?
			if ((vars.goals[goal][vars.curroom] != -1) && (current.room != vars.goals[goal][vars.curroom]))
				continue;

			// is there an old room requirement?
			if ((vars.goals[goal][vars.oldroom] != -1) && (old.room != vars.goals[goal][vars.oldroom]))
				continue;

			// is there an exact plot requirement?
			if ((vars.goals[goal][vars.reqplot] != -1) && (current.plot != vars.goals[goal][vars.reqplot]))
				continue;

			// is there a maximum plot requirement?
			if ((vars.goals[goal][vars.maxplot] != -1) && (current.plot > vars.goals[goal][vars.maxplot]))
				continue;

			// is there a current fight requirement ?
			if ((vars.goals[goal][vars.curfight] != -1) && (current.fight != vars.goals[goal][vars.curfight]))
				continue;

			// is there an old fight requirement ?
			if ((vars.goals[goal][vars.oldfight] != -1) && (old.fight != vars.goals[goal][vars.oldfight]))
				continue;
				
			// is there a special flag requirement?
			if (vars.goals[goal][vars.special] != -1)
			{
				bool pass = false;

				switch((int)vars.goals[goal][vars.special])
				{
					case 1:		// theendboxclosed
						/*
						When the final textbox is closed, the game stores global.filechoice in a temp var
						it then sets global.filechoice + 3, saves the game, and then sets it back
						we can use this to get the frame after the textbox was closed by looking for filechoice > 2
						as this will only be valid in this one case
						*/
						pass = (current.filechoice > 2);
						break;

					case 2:		// theendselfdestroyed
						/*
						We dig out the haltstate of the final textbox. When it's in state 2, it's done writing.
						Once the box is dismised, the pointer becomes invalid and as such, the value is no longer 2
						We also check to make sure they took choice 0 and not choice 1 to ensure they chose yes and not no.
						*/
						pass = (((old.finalTextboxHalt == 2 && current.finalTextboxHalt != 2) || (old.finalTextboxHalt2 == 2 && current.finalTextboxHalt2 != 2))  && current.choicer == 0);
						break;

					case 3:		// i-key
						pass = vars.checkKeyItems(5);
						break;

					case 4:		// i-keyA
						pass = vars.checkKeyItems(4);
						break;

					case 5:		// i-keyB
						pass = vars.checkKeyItems(6);
						break;

					case 6:		// i-keyC
						pass = vars.checkKeyItems(7);
						break;
						
					case 7: //b-jevilEnd 
						/*
						Jevil has a variable named dancelv which sets the sprite/animation he's using
						0 - Default, 1 - Bounce, 2 - Sad, 3 - Teleports, 4 - Dead
						We use this to determine when he's been pacified
						*/
						pass = (current.jevilDance == 4 || current.jevilDance2 == 4);
						break;
				}

				if (!pass)
					continue;
			}

			// if we get to this point, all requirements are met
			vars.goals[goal][vars.visited] = true;

				vars.log("i");
			vars.log("SPLIT  name:" + goal + 
				" oldroom:" + vars.goals[goal][vars.oldroom] + 
				" curroom:" + vars.goals[goal][vars.curroom] + 
				" reqplot:" + vars.goals[goal][vars.reqplot] + 
				" maxplot:" + vars.goals[goal][vars.maxplot] + 
				" oldfight:" + vars.goals[goal][vars.oldfight] + 
				" curfight:" + vars.goals[goal][vars.curfight] + 
				" special:" + vars.goals[goal][vars.special]);

			return true;
		}
	}
	return false;
}