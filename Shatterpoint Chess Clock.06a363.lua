TimerID  = ""     Colons      = true
holding  = false  holdTime    = 0
holding_1= false  hold_1Time  = 0
holding_2= false  hold_2Time  = 0
holding_3= false  hold_3Time  = 0

standardClockColor={0.411765, 0.396078, 0.384314}
missionCriticalClockColor={1,1,0}
unColoredColor = {105/255,101/255,98/255}
holdColor_1 ="" holdColor_2 ="" holdColor_3 ="" holdColor=""
holdPlayer_1="" holdPlayer_2="" holdPlayer_2=""

defaults = {
	start_1  = 0      ,start_2     = 0		,start_3     = 0,
	seconds_1= 0      ,seconds_2   = 0		,seconds_3   = 0,
	bonus_1  = 0      ,bonus_2     = 0		,bonus_3     = 0,
	delay_1  = 0      ,delay_2     = 0		,delay_3     = 0,
	selDigit = 6      ,delayed     = 0,
	state    = 11     ,storedState = 11,
	ended_1  = true   ,ended_2     = true	,ended_3     = true,
	DoTurns  = false  ,color_1="", color_2="", countDirection = -1,
}

data = defaults

HOLD = 1 RESOLUTION = 0.25
tmpDigits =  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
digitNames = {"Hr1_1","Mn1_10","Mn1_01","Sc1_10","Sc1_01","Hr2_1","Mn2_10","Mn2_01","Sc2_10","Sc2_01", "Hr3_1","Mn3_10","Mn3_01","Sc3_10","Sc3_01"}
states = {"increment_1","increment_2","decrement_1","decrement_2","adjustTime","setTime","setBonus","setDelay","doDelay_1","doDelay_2","Paused", "PausePlayer"}
--            1                2            3            4            5            6          7         8          9           10        11			  12

function onSave()
	self.script_state = JSON.encode(data)
    return self.script_state
end

function onLoad(json)
	self.createButton({
		click_function = "Click_1",
		function_owner = self,
		label          = "",
		position       = {5.75,2.75,-1},
		rotation       = {0,0,0},
		scale          = {1,1,1},
		width          = 1000,
		height         = 1000,
		color          = {0, 0, 0, 0.01},
		font_color     = {0, 0, 0, 100},
		tooltip        = "Swap Timer"
	})

	self.createButton({
		click_function = "Click_2",
		function_owner = self,
		label          = "",
		position       = {-5.75,2.75,-1},
		rotation       = {0,0,0},
		scale          = {1,1,1},
		width          = 1000,
		height         = 1000,
		color          = {0, 0, 0, 0.01},
		font_color     = {0, 0, 0, 100},
		tooltip        = "Swap Timer"
	})

	if data.state > 4 then leftButton = "Start\nMain\nClock" else leftButton = "Pause\nPlayer\nClocks" end

	self.createButton({
		click_function = "startClock",
		function_owner = self,
		label          = leftButton,
		position       = {-2.95,2.77,-0.97},
		rotation       = {0,0,0},
		scale          = {1,1,1},
		width          = 600,
		height         = 600,
		font_size	   = 170,
		color          = {0, 0, 0, 0.01},
		font_color     = {0, 0, 0, 100},
		tooltip        = "Pauses player clocks and starts game clock."
	})

	if data.countDirection == 1 then strDirection = "Up" else strDirection = "Down" end

	self.createButton({
		click_function = "toggleDirection",
		function_owner = self,
		label          = "Count:\n" .. strDirection,
		position       = {2.95,2.77,-0.97},
		rotation       = {0,0,0},
		scale          = {1,1,1},
		width          = 600,
		height         = 600,
		font_size	   = 150,
		color          = {0, 0, 0, 0.01},
		font_color     = {0, 0, 0, 100},
		tooltip        = "Toggle Between Increment and Decrement"
	})

	self.createButton({
		click_function = "Click_C",
		function_owner = self,
		label          = "Pause\nAll\nClocks",
		position       = {0,2.77,-0.97},
		rotation       = {0,0,0},
		scale          = {1,1,1},
		width          = 600,
		height         = 600,
		font_size	   = 170,
		color          = {0, 0, 0, 0.01},
		font_color     = {0, 0, 0, 100},
		tooltip        = "Pause All Timers"
	})



	if json~="" then
		data = JSON.decode(json)
	else
		data.seconds_1 = data.start_1 data.seconds_2 = data.start_2 data.seconds_3 = data.start_3
	end
    DisplayClock(1, data.seconds_1)
    DisplayClock(2, data.seconds_2)
	DisplayClock(3, data.seconds_3)
    TimerID = "Gizmo_ChessClock_"..os.time()
    Timer.create({identifier=TimerID, function_name="Tick", delay=RESOLUTION, repetitions=0})
end

function Tick()
    self.call(states[data.state],{})
	if data.state != 11 then increment_3() end
    if holding==true then
		if holdColor == "Grey" or (data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black") then
            return
        end
        holdTime = holdTime+RESOLUTION
    end
    if holding_1==true then
        hold_1Time = hold_1Time+RESOLUTION
    end
    if holding_2==true then
        hold_2Time = hold_2Time+RESOLUTION
    end
end

function Click_1(obj, player)
	if hold_1Time<HOLD then
        if data.ended_2==true and data.seconds_2==0 then
            data.storedState=11 data.ended_2=false
            data.seconds_2 = data.start_2
        end
        if data.state==12 or data.state==11 or data.state==1 or data.state==3 or data.state==9 then
            Resume()
            if data.start_2==0 then
                data.seconds_2 = data.seconds_2-data.bonus_2
                if data.delay_2==0 then
                    data.state = 2
                else
                    data.delayed = data.delay_2
                    data.state = 10
                end
            else
                data.seconds_2 = data.seconds_2+data.bonus_2
                if data.delay_2==0 then
                    data.state = 4
                else
                    data.delayed = data.delay_2
                    data.state = 10
                end
            end
            SetTurn()
        elseif data.state==5 or data.state==6 then
            tmpDigits[data.selDigit] = tmpDigits[data.selDigit]+1
            if data.selDigit==1 or data.selDigit==3 or data.selDigit==5 or data.selDigit==6 or data.selDigit==8 or data.selDigit==10 then
                if tmpDigits[data.selDigit] > 9 then
                    tmpDigits[data.selDigit]=0
                end
            else
                if tmpDigits[data.selDigit] > 5 then
                    tmpDigits[data.selDigit]=0
                end
            end
            self.UI.show(digitNames[data.selDigit])
            self.UI.setAttribute(digitNames[data.selDigit] , "image", tmpDigits[data.selDigit])
        elseif data.state==7 or data.state==8 then
            tmpDigits[data.selDigit] = tmpDigits[data.selDigit]+1
            if data.selDigit==5 or data.selDigit==10 then
                if tmpDigits[data.selDigit] > 9 then
                    tmpDigits[data.selDigit]=0
                end
            else
                if tmpDigits[data.selDigit] > 5 then
                    tmpDigits[data.selDigit]=0
                end
            end
            self.UI.show(digitNames[data.selDigit])
            self.UI.setAttribute(digitNames[data.selDigit] , "image", tmpDigits[data.selDigit])
        end
    end
    holding_1=false
    hold_1Time=0
	self.editButton({index = 2, label = "Pause\nPlayer\nClocks"})
end
function Click_2(obj, player, _, _)
	if hold_2Time<HOLD then
        if data.ended_1==true and data.seconds_1==0 then
            data.storedState=11 data.ended_1=false
            data.seconds_1 = data.start_1
        end
        if data.state==12 or data.state==11 or data.state==2 or data.state==4 or data.state==10 then
            Resume()
            if data.start_1==0 then
                data.seconds_1 = data.seconds_1-data.bonus_1
                if data.delay_1==0 then
                    data.state = 1
                else
                    data.delayed = data.delay_1
                    data.state = 9
                end
            else
                data.seconds_1 = data.seconds_1+data.bonus_1
                if data.delay_1==0 then
                    data.state = 3
                else
                    data.delayed = data.delay_1
                    data.state = 9
                end
            end
            SetTurn()
        elseif data.state==5 or data.state==6 then
            tmpDigits[data.selDigit] = tmpDigits[data.selDigit]-1
            if tmpDigits[data.selDigit] < 0 then
                if data.selDigit==1 or data.selDigit==3 or data.selDigit==5 or data.selDigit==6 or data.selDigit==8 or data.selDigit==10 then
                    tmpDigits[data.selDigit]=9
                else
                    tmpDigits[data.selDigit]=5
                end
            end
            self.UI.show(digitNames[data.selDigit])
            self.UI.setAttribute(digitNames[data.selDigit] , "image", tmpDigits[data.selDigit])
        elseif data.state==7 or data.state==8 then
            tmpDigits[data.selDigit] = tmpDigits[data.selDigit]-1
            if tmpDigits[data.selDigit] < 0 then
                if data.selDigit==5 or data.selDigit==10 then
                    tmpDigits[data.selDigit]=9
                else
                    tmpDigits[data.selDigit]=5
                end
            end
            self.UI.show(digitNames[data.selDigit])
            self.UI.setAttribute(digitNames[data.selDigit] , "image", tmpDigits[data.selDigit])
        end
    end
    holding_2=false
    hold_2Time=0
	self.editButton({index = 2, label = "Pause\nPlayer\nClocks"})
end

function startClock(obj, player, _, _)
	data.state=12
end

function Click_White()
	if data.state == 11 then
		startClock()
	else
		data.state = 11
	end
end

function Click_C(player, _, _)
	if holdTime<HOLD then
        if data.state==1 or data.state==2 or data.state==3 or data.state==4 or data.state==9 or data.state==10 or data.state==12 then
            Pause()
        elseif data.state==11 and data.storedState~=0 then
            Resume()
            SetTurn()
        elseif data.state==5 or data.state==6 then
            self.UI.show(digitNames[data.selDigit])
            if data.selDigit==5 then
                if data.state==6 then
                    tmpToStartSec()
                    secsToTmp(data.bonus_1, data.bonus_2)
                    data.state = 7
                    data.selDigit = 9

                    HideDigits()
                    DisplayClock(2, data.bonus_2)
                    self.UI.setAttribute("Hr2_1" , "image", "b")
                else
                    data.state = 11
                    data.selDigit = 6
                    adj = tmpToSecs()
                    data.seconds_1 = adj[1] data.seconds_2 = adj[2]
                    DisplayClock(1, data.seconds_1)
                    DisplayClock(2, data.seconds_2)
					DisplayClock(3, data.seconds_3)
                    ShowDigits()
                end
            else
                data.selDigit = data.selDigit+1
                if data.selDigit>10 then
                    if data.state==6 then
                        tmpDigits[1]=tmpDigits[6]
                        tmpDigits[2]=tmpDigits[7]
                        tmpDigits[3]=tmpDigits[8]
                        tmpDigits[4]=tmpDigits[9]
                        tmpDigits[5]=tmpDigits[10]
                        tmpToStartSec()
                        DisplayClock(1, data.start_1)
                    end
                    data.selDigit=1
                end
            end
        elseif data.state==7 then
            self.UI.show(digitNames[data.selDigit])
            if data.selDigit==5 then
                bon = tmpToSecs() data.bonus_1 = bon[1] data.bonus_2 = bon[2]
                secsToTmp(data.delay_1, data.delay_2)
                data.state = 8
                data.selDigit = 9

                HideDigits()
                DisplayClock(2, data.delay_2)
                self.UI.setAttribute("Hr2_1" , "image", "d")
            else
                data.selDigit = data.selDigit+1
                if data.selDigit>10 then
                    tmpDigits[4]=tmpDigits[9]
                    tmpDigits[5]=tmpDigits[10]
                    bon = tmpToSecs()
                    DisplayClock(1, bon[1])
                    self.UI.setAttribute("Hr1_1" , "image", "b")
                    data.selDigit=4
                end
            end
        elseif data.state==8 then
            self.UI.show(digitNames[data.selDigit])
            if data.selDigit==5 then
                del = tmpToSecs() data.delay_1 = del[1] data.delay_2 = del[2]
                data.state = 11
                data.selDigit = 6
                data.seconds_1 = data.start_1 data.seconds_2 = data.start_2
                DisplayClock(1, data.seconds_1)
                DisplayClock(2, data.seconds_2)
				DisplayClock(3, data.seconds_3)
                ShowDigits()
            else
                data.selDigit = data.selDigit+1
                if data.selDigit>10 then
                    tmpDigits[4]=tmpDigits[9]
                    tmpDigits[5]=tmpDigits[10]
                    del = tmpToSecs()
                    DisplayClock(1, del[1])
                    self.UI.setAttribute("Hr1_1" , "image", "d")
                    data.selDigit=4
                end
            end
        end
    end
    holding=false
    holdTime=0
	self.editButton({index = 2, label = "Start\nGame\nClock"})
end
function Hold_C(player, _, _)
	if player.color == "Grey" then
		return
	end
    holding=true
    holdColor = player.color
end
function Hold_1(player, _, _)
	if player.color == "Grey" then
		return
	end
    holdColor_1 = player.color
    holdPlayer_1 = player.steam_name
    holding_1=true
end
function Hold_2(player, _, _)
	if player.color == "Grey" then
		return
	end
    holdColor_2 = player.color
    holdPlayer_2 = player.steam_name
    holding_2=true
end

function Pause()
    data.storedState=data.state
    data.state=11
    if data.DoTurns==true then
        self.setColorTint(unColoredColor)
        Turns.enable=false
    end
end
function Resume()
    data.state=data.storedState
    data.storedState=11
end
function SetTurn()
    if data.DoTurns==true then
--      Turns.type=2
--      Turns.pass_turns=false
--      Turns.skip_empty_hands=false
--      Turns.disable_interactations=true
        if data.state==1 or data.state==3 or data.state==9 then
            self.setColorTint(stringColorToRGB(data.color_1))
--          Turns.order={data.color_1}
--          Turns.turn_color=data.color_1
        elseif data.state==2 or data.state==4 or data.state==10 then
            self.setColorTint(stringColorToRGB(data.color_2))
--          Turns.order={data.color_2}
--          Turns.turn_color=data.color_2
        end
--      Turns.enable=true
    end
end

function HideDigits()
    for i=1,10,1 do
        self.UI.hide(digitNames[i])
    end
end
function ShowDigits()
    for i=1,10,1 do
        self.UI.show(digitNames[i])
    end
end


function Paused()
    TurnCheck()
	    if data.storedState~=9 and data.storedState~=10 then
		        DisplayClock(1, data.seconds_1)
		        DisplayClock(2, data.seconds_2)
				DisplayClock(3, data.seconds_3)
		        ShowDigits()
	    end
    if holdTime==HOLD then
        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
            return
        end
        data.state=6
        secsToTmp(data.start_1, data.start_2)
        DisplayClock(1, data.start_1)
        DisplayClock(2, data.start_2)
    elseif Colons==true then
        if data.storedState==11 then

        elseif data.storedState==1 or data.storedState==3 then
		        elseif data.storedState==9 then
			            HideDigits()
			            self.UI.show(digitNames[4])
			            self.UI.show(digitNames[5])
			            DisplayClock(1, data.delayed)
        elseif data.storedState==2 or data.storedState==4 then
		        elseif data.storedState==10 then
			            HideDigits()
			            self.UI.show(digitNames[9])
			            self.UI.show(digitNames[10])
			            DisplayClock(2, data.delayed)
        end
        Colons = false
        return
    end

    Colons = true
end

function DisplayClock(which, value)
    secs = value
    hours = secs/3600
    secs = secs%3600
    minutes = secs/60
    secs = secs%60
    self.UI.setAttribute("Hr"..which.."_1" , "image", math.floor(hours%10))
    self.UI.setAttribute("Mn"..which.."_10", "image", math.floor(minutes/10))
    self.UI.setAttribute("Mn"..which.."_01", "image", math.floor(minutes%10))
    self.UI.setAttribute("Sc"..which.."_10", "image", math.floor(secs/10))
    self.UI.setAttribute("Sc"..which.."_01", "image", math.floor(secs%10))
	Global.UI.setAttribute("Hr"..which.."_1" , "image", math.floor(hours%10))
	Global.UI.setAttribute("Mn"..which.."_10", "image", math.floor(minutes/10))
	Global.UI.setAttribute("Mn"..which.."_01", "image", math.floor(minutes%10))
	Global.UI.setAttribute("Sc"..which.."_10", "image", math.floor(secs/10))
	Global.UI.setAttribute("Sc"..which.."_01", "image", math.floor(secs%10))

    if value <= 1800 then
        self.setColorTint(missionCriticalClockColor)
    else
        self.setColorTint(standardClockColor)
    end
end

function increment_1()
    if holdTime==HOLD then
        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
            return
        end
        if data.DoTurns==true then
            self.setColorTint(unColoredColor)
            Turns.enable=false
        end
        data.storedState=data.state
        data.state=5
        secsToTmp(data.seconds_1, data.seconds_2, data.seconds_3)
        DisplayClock(1, data.seconds_1)
        DisplayClock(2, data.seconds_2)
		DisplayClock(3, data.seconds_3)
    elseif holdTime==0 then
        DisplayClock(1, data.seconds_1)
        data.seconds_1=data.seconds_1+RESOLUTION*data.countDirection

    end
end
function increment_2()
    if holdTime==HOLD then
        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
            return
        end
        if data.DoTurns==true then
            self.setColorTint(unColoredColor)
            Turns.enable=false
        end
        data.storedState=data.state
        data.state=5
        secsToTmp(data.seconds_1, data.seconds_2, data.seconds_3)
        DisplayClock(1, data.seconds_1)
        DisplayClock(2, data.seconds_2)
		DisplayClock(3, data.seconds_3)
    elseif holdTime==0 then
        DisplayClock(2, data.seconds_2)
        data.seconds_2=data.seconds_2+RESOLUTION*data.countDirection
    end
end
function increment_3()

    DisplayClock(3, data.seconds_3)
    data.seconds_3=data.seconds_3+RESOLUTION*data.countDirection
end
function PausePlayer()

end
function decrement_1()
    if holdTime==HOLD then
        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
            return
        end
        if data.DoTurns==true then
            self.setColorTint(unColoredColor)
            Turns.enable=false
        end
        data.storedState=data.state
        data.state=5
        secsToTmp(data.seconds_1, data.seconds_2, data.seconds_3)
        DisplayClock(1, data.seconds_1)
        DisplayClock(2, data.seconds_2)
		DisplayClock(3, data.seconds_3)
    elseif holdTime==0 then


        DisplayClock(1, data.seconds_1)
        data.seconds_1 = data.seconds_1-RESOLUTION
        if data.seconds_1 < 0 then
            Ding()
            data.ended_1=true
            data.state=11
            data.storedState=data.state
        end
    end
end
function decrement_2()
    if holdTime==HOLD then
        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
            return
        end
        if data.DoTurns==true then
            self.setColorTint(unColoredColor)
            Turns.enable=false
        end
        data.storedState=data.state
        data.state=5
        secsToTmp(data.seconds_1, data.seconds_2, data.seconds_3)
        DisplayClock(1, data.seconds_1)
        DisplayClock(2, data.seconds_2)
		DisplayClock(3, data.seconds_3)
    elseif holdTime==0 then


        DisplayClock(2, data.seconds_2)
        data.seconds_2 = data.seconds_2-RESOLUTION
        if data.seconds_2 < 0 then
            Ding()
            data.ended_2=true
            data.state=11
            data.storedState=data.state
        end
    end
end

function adjustTime()
    if holdTime==HOLD then
        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
            return
        end
        data.state=11 data.storedState=11 data.selDigit=6
        data.seconds_1 = data.start_1 data.seconds_2 = data.start_2 data.seconds_3 = data.start_3
        DisplayClock(1, data.start_1)
        DisplayClock(2, data.start_2)
		DisplayClock(3, data.start_3)
    else

        for i=1,10,1 do
            if i~=data.selDigit then
                self.UI.show(digitNames[i])
            end
        end
        if Colons==true then
            self.UI.hide(digitNames[data.selDigit])
            Colons = false
        else
            self.UI.show(digitNames[data.selDigit])
            Colons = true
        end
    end
end
function setTime()
    if holdTime==HOLD then
        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
            return
        end
        data.state=11 data.storedState=11 data.selDigit=6
		        tmpToStartSec()
        data.seconds_1 = data.start_1 data.seconds_2 = data.start_2 data.seconds_3 = data.start_3
        DisplayClock(1, data.start_1)
        DisplayClock(2, data.start_2)
		DisplayClock(3, data.start_3)
    else

		        for i=1,10,1 do
			            if i~=data.selDigit then
				                self.UI.show(digitNames[i])
			            end
		        end
		        if Colons==true then
			            self.UI.hide(digitNames[data.selDigit])

			            Colons = false
		        else
			            self.UI.show(digitNames[data.selDigit])

			            Colons = true
		        end
	    end
end
function setBonus()
    if holdTime==HOLD then
        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
            return
        end
        data.state=11 data.storedState=11 data.selDigit=6
		        bon = tmpToSecs() data.bonus_1 = bon[1] data.bonus_2 = bon[2]
        data.seconds_1 = data.start_1 data.seconds_2 = data.start_2 data.seconds_3 = data.start_3
        DisplayClock(1, data.start_1)
        DisplayClock(2, data.start_2)
		DisplayClock(3, data.start_3)
    else
        		count=2
		        if data.selDigit>5 then
			            self.UI.show("Hr2_1")
			            burp={9,10}
		        else
			            self.UI.show("Hr1_1")
			            burp={4,5,9,10}
			            count=4
		        end

		        for i=1,count,1 do
    			        if burp[i]~=data.selDigit then
				                self.UI.show(digitNames[burp[i]])
			            end
		        end
		        if Colons==true then
    			        self.UI.hide(digitNames[data.selDigit])
			            Colons = false
		        else
			            self.UI.show(digitNames[data.selDigit])
			            Colons = true
		        end
	    end
end
function setDelay()
    if holdTime==HOLD then
        if data.DoTurns == true and data.color_1 ~= holdColor and data.color_2 ~= holdColor and holdColor ~= "Black" then
            return
        end
        data.state=11 data.storedState=11 data.selDigit=6
        		del = tmpToSecs() data.delay_1 = del[1] data.delay_2 = del[2]
        data.seconds_1 = data.start_1 data.seconds_2 = data.start_2 data.seconds_3 = data.start_3
        DisplayClock(1, data.start_1)
        DisplayClock(2, data.start_2)
		DisplayClock(3, data.start_3)
    else
		count=2
        if data.selDigit>5 then
	            self.UI.show("Hr2_1")
	            burp={9,10}
        else
	            self.UI.show("Hr1_1")
	            burp={4,5,9,10}
	            count=4
        end

        for i=1,2,1 do
	            if burp[i]~=data.selDigit then
		                self.UI.show(digitNames[burp[i]])
	            end
        end
        if Colons==true then
	            self.UI.hide(digitNames[data.selDigit])
	            Colons = false
        else
	            self.UI.show(digitNames[data.selDigit])
	            Colons = true
        end
    end
end

function doDelay_1()

    if data.delayed==0 then

        ShowDigits()
        DisplayClock(1, data.seconds_1)
        DisplayClock(2, data.seconds_2)
		DisplayClock(3, data.seconds_3)
        if data.start_1==0 then
            data.state = 1
        else
            data.state = 3
        end
    else

        HideDigits()
        self.UI.show(digitNames[4])
        self.UI.show(digitNames[5])
        DisplayClock(1, data.delayed)
        data.delayed=data.delayed-RESOLUTION
    end
end

function doDelay_2()

    if data.delayed==0 then

        ShowDigits()
        DisplayClock(1, data.seconds_1)
        DisplayClock(2, data.seconds_2)
		DisplayClock(3, data.seconds_3)
        if data.start_2==0 then
            data.state = 2
        else
            data.state = 4
        end
    else

        HideDigits()
        self.UI.show(digitNames[9])
        self.UI.show(digitNames[10])
        DisplayClock(2, data.delayed)
        data.delayed=data.delayed-RESOLUTION
    end
end

function secsToTmp(secs_1, secs_2)
    secs = secs_1
    hours = secs/3600
    secs = secs%3600
    minutes = secs/60
    secs = secs%60
    tmpDigits[1] = math.floor(hours%10)
    tmpDigits[2] = math.floor(minutes/10)
    tmpDigits[3] = math.floor(minutes%10)
    tmpDigits[4] = math.floor(secs/10)
    tmpDigits[5] = math.floor(secs%10)
    secs = secs_2
    hours = secs/3600
    secs = secs%3600
    minutes = secs/60
    secs = secs%60
    tmpDigits[6] = math.floor(hours%10)
    tmpDigits[7] = math.floor(minutes/10)
    tmpDigits[8] = math.floor(minutes%10)
    tmpDigits[9] = math.floor(secs/10)
    tmpDigits[10]= math.floor(secs%10)
end
function tmpToStartSec()
    data.start_1=(tmpDigits[1]*3600)+(tmpDigits[2]*600)+(tmpDigits[3]*60)+(tmpDigits[4]*10)+tmpDigits[5]
    data.start_2=(tmpDigits[6]*3600)+(tmpDigits[7]*600)+(tmpDigits[8]*60)+(tmpDigits[9]*10)+tmpDigits[10]
end
function tmpToSecs()
    return {(tmpDigits[1]*3600)+(tmpDigits[2]*600)+(tmpDigits[3]*60)+(tmpDigits[4]*10)+tmpDigits[5], (tmpDigits[6]*3600)+(tmpDigits[7]*600)+(tmpDigits[8]*60)+(tmpDigits[9]*10)+tmpDigits[10]}
end
function Ding()
    Timer.create({identifier=os.time(), function_name="Dong", delay=0.025, repetitions=50})
end
function Dong()
    pos = self.getPosition()
    pos.y = pos.y+0.125
    self.setPosition(pos)
    self.setVelocity({0,-200,0})
end
function TurnCheck()
    if hold_1Time==HOLD then
        if data.DoTurns==false then
            data.color_1=holdColor_1
            if data.color_2~="" then
                broadcastToAll("Color-Mode Enabled.", {0,1,0})
                data.DoTurns=true
            else
                broadcastToAll("Waiting For Player 2...", {1,1,1})
            end
            broadcastToAll("Set Player 1 to "..holdPlayer_1.." ("..holdColor_1..")", {0.5,0.5,1})
        elseif holdColor_1==data.color_1 or holdColor_1==data.color_2 or holdColor_1=="Black" then
            broadcastToAll("Color-Mode Disabled.", {1,0,0})
            data.DoTurns=false
            data.color_1=""
            data.color_2=""
            self.setColorTint(unColoredColor)
        end
    end
    if hold_2Time==HOLD then
        if data.DoTurns==false then
            data.color_2=holdColor_2
            if data.color_1~="" then
                broadcastToAll("Color-Mode Enabled.", {0,1,0})
                data.DoTurns=true
            else
                broadcastToAll("Waiting For Player 1...", {1,1,1})
            end
            broadcastToAll("Set Player 2 to "..holdPlayer_2.." ("..holdColor_2..")", {0.5,0.5,1})
        elseif holdColor_2==data.color_1 or holdColor_2==data.color_2 or holdColor_2=="Black" then
            broadcastToAll("Color-Mode Disabled.", {1,0,0})
            data.DoTurns=false
            data.color_1=""
            data.color_2=""
            self.setColorTint(unColoredColor)
        end
    end
end

function setClock(player, click, id)
	local offset = 0
	if click == "-1" then
		offset = 1
	elseif click == "-2" then
		offset = -1
	end

	if id == "Sc1_01" then
		data.seconds_1 = data.seconds_1 + 1*offset
	elseif id == "Sc1_10" then
		data.seconds_1 = data.seconds_1 + 10*offset
	elseif id == "Mn1_01" then
		data.seconds_1 = data.seconds_1 + 60*offset
	elseif id == "Mn1_10" then
		data.seconds_1 = data.seconds_1 + 600*offset
	elseif id == "Hr1_1" then
		data.seconds_1 = data.seconds_1 + 3600*offset
	elseif id == "Sc2_01" then
		data.seconds_2 = data.seconds_2 + 1*offset
	elseif id == "Sc2_10" then
		data.seconds_2 = data.seconds_2 + 10*offset
	elseif id == "Mn2_01" then
		data.seconds_2 = data.seconds_2 + 60*offset
	elseif id == "Mn2_10" then
		data.seconds_2 = data.seconds_2 + 600*offset
	elseif id == "Hr2_1" then
		data.seconds_2 = data.seconds_2 + 3600*offset
	elseif id == "Sc3_01" then
		data.seconds_3 = data.seconds_3 + 1*offset
	elseif id == "Sc3_10" then
		data.seconds_3 = data.seconds_3 + 10*offset
	elseif id == "Mn3_01" then
		data.seconds_3 = data.seconds_3 + 60*offset
	elseif id == "Mn3_10" then
		data.seconds_3 = data.seconds_3 + 600*offset
	elseif id == "Hr3_1" then
		data.seconds_3 = data.seconds_3 + 3600*offset
	end
	DisplayClock(1, data.seconds_1)
	DisplayClock(2, data.seconds_2)
	DisplayClock(3, data.seconds_3)
end

function toggleDirection()
	if data.countDirection == -1 then
		data.countDirection = 1
		self.editButton({index = 3, label = "Count:\nUp"})
	else
		data.countDirection = -1
		self.editButton({index = 3, label = "Count:\nDown"})
	end
end