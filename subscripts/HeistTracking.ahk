;    PoE-Enchantress a pricing tool for things which cannot be copied
;    Copyright (C) 2021 LawTotem#8511

;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.

;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.

;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <https://www.gnu.org/licenses/>.

global OldInventory := ""

global isBlueprint := false
global hasKarst := false
global hasNiles := false
global hasHuck := false
global hasTibbs := false
global hasNenet := false
global hasVinderi := false
global hasTullina := false
global hasIlsa := false
global hasGianna := false

global heistLootType := []
global heistLootCount := []
global ClientTxt = 0

global HeistTimerState := 0
global HeistTimerStart := 0
global HeistTimerGrab := 0
global HeistTimerStop := 0

newRecordWindow()
addNewSetting("General", "ClientTxt", "C:\Program Files (x86)\Grinding Gear Games\Path of Exile\logs\Client.txt", "Location of Client.txt")
addNewSetting("User", "POESESSID", "", "The POESESSID cookie")
addNewSetting("User", "Account", "", "Your Account Name")
addNewSetting("User", "Character", "", "Your Character Name")

newRecordWindow()
{
    global
    Gui, RecordHeist:New,, PoE-Enchantress Heist Timer

    Gui, Color, 0x192020, 0x251e16
    Gui, Font, cB60C0C s20

    Gui, add, text, x5 y5 vHeistMainTime gResetHeistTime, 00:00.0

    Gui, Font
    Gui, Font, ce7b477 s11
    Gui, add, text, x120 y3, Grab
    Gui, add, text, x120 y20 vHeistGrabTime, 00:00.0
    Gui, add, text, x180 y3, Complete
    Gui, add, text, x180 y20 vHeistCompleteTime, 00:00.0
    Gui, add, text, x250 y10 vHeistBlueprint gSelectBlueprint, Blueprint
    Gui, add, text, x5 y40 w60 vHeistKarst gSelectKarst, Karst
    Gui, add, text, x75 y40 w60 vHeistNiles gSelectNiles, Niles
    Gui, add, text, x145 y40 w60 vHeistHuck gSelectHuck, Huck
    Gui, add, text, x215 y40 w60 vHeistTibbs gSelectTibbs, Tibbs
    Gui, add, text, x285 y40 w60 vHeistGianna gSelectGianna, Gianna
    Gui, add, text, x5 y60 w60 vHeistNenet gSelectNenet, Nenet
    Gui, add, text, x75 y60 w60 vHeistVinderi gSelectVinderi, Vinderi
    Gui, add, text, x145 y60 w60 vHeistTullina gSelectTullina, Tullina
    Gui, add, text, x215 y60 w60 vHeistIsla gSelectIlsa, Isla

    addHeistLoot(5,80,1,"Abyss")
    addHeistLoot(50,80,2,"Armour")
    addHeistLoot(95,80,3,"Blight")
    addHeistLoot(140,80,4,"Breach")
    addHeistLoot(185,80,5,"Currency")
    addHeistLoot(230,80,6,"Delirium")
    addHeistLoot(275,80,7,"Divination")
    addHeistLoot(5,120,8,"Essences")
    addHeistLoot(50,120,9,"Fossils")
    addHeistLoot(95,120,10,"Fragments")
    addHeistLoot(140,120,11,"Gems")
    addHeistLoot(185,120,12,"Generic")
    addHeistLoot(230,120,13,"Harbinger")
    addHeistLoot(275,120,14,"Legion")

    addHeistLoot(5,160,15,"Trinkets")
    addHeistLoot(50,160,16,"Uniques")
    addHeistLoot(95,160,17,"Talismans")
    addHeistLoot(140,160,18,"Maps")
    addHeistLoot(185,160,19,"Metamorph")
    addHeistLoot(230,160,20,"Prophecies")
    addHeistLoot(275,160,21,"Weapon")
    addHeistLoot(320,160,22,"Small")
    
    Gui, RecordHeist:+AlwaysOnTop -SysMenu
    
    Gui, RecordHeist:Show
}

initTimer()
{
    global ClientTxt
    ClientTxt := FileOpen(getSetting("General","ClientTxt"),"r")
    if (ClientTxt = 0)
    {
        return false
    }
    else
    {
        ClientTxt.Read()
        Gui, RecordHeist:Font, ce7b477 s20
        GuiControl, RecordHeist:Font, HeistMainTime
        SetTimer, HeistTicker, 50
        Gui, RecordHeist:Show
        return true
    }
}

startTimer()
{
    Gui, RecordHeist:Font, c0CB60C s20
    GuiControl, RecordHeist:Font, HeistMainTime
    GuiControl, RecordHeist:, HeistMainTime, 00:00.0
    GuiControl, RecordHeist:, HeistGrabTime, 00:00.0
    GuiControl, RecordHeist:, HeistCompleteTime, 00:00.0
    global HeistTimerStart
    HeistTimerStart := A_TickCount
    global HeistTimerState
    HeistTimerState := 1
    global OldInventory
    OldInventory := getInventory()
}

selectRecord(record, value)
{
    if (value)
    {
        Gui, RecordHeist:Font, cB60C0C s11
        GuiControl, RecordHeist:Font, %record%
        return true
    }
    else
    {
        Gui, RecordHeist:Font, cE7B477 s11
        GuiControl, RecordHeist:Font, %record%
        return false
    }
}

toggleRecord(record, value)
{
    if (value)
    {
        return selectRecord(record, false)
    }
    else
    {
        return selectRecord(record, true)
    }
}

addHeistLoot(xx,yy,index,loot)
{
    global
    Gui, RecordHeist:add, picture, x%xx% y%yy% w40 h40 gHeistLoot_%index%, resources\HeistReward%loot%.png
    Gui, RecordHeist:font, s8
    local oxx,oyy
    oxx := xx + 33
    oyy := yy + 25
    Gui, RecordHeist:add, text, x%oxx% y%oyy% vHeistLoot_%index%, 0
    heistLootType[index] := loot
    heistLootCount[index] := 0
}

indexLoot(index)
{
    global
    heistLootCount[index] += 1
    if (heistLootCount[index] = 10)
    {
        heistLootCount[index] := 0
    }
    setHeistLoot(index, heistLootCount[index])
}
setHeistLoot(index, value)
{
    global
    heistLootCount[index] := value
    GuiControl, RecordHeist:, HeistLoot_%index%, %value%
}

resetHeistRecord()
{
    global
    isBlueprint := selectRecord("HeistBlueprint", false)
    hasKarst := selectRecord("HeistKarst", false)
    hasNiles := selectRecord("HeistNiles", false)
    hasHuck := selectRecord("HeistHuck", false)
    hasTibbs := selectRecord("HeistTibbs", false)
    hasNenet := selectRecord("HeistNenet", false)
    hasVinderi := selectRecord("HeistVinderi", false)
    hasTullina := selectRecord("HeistTullina", false)
    hasIsla := selectRecord("HeistIsla", false)
    hasGianna := selectRecord("HeistGianna", false)
    loop, 22
    {
        setHeistLoot(A_Index,0)
    }
    HeistTimerState := 0
}

checkLineHas(line, things)
{
    loop % things.Length()
    {
        vv := things[A_Index]
        if (InStr(line, vv, true))
        {
            return true
        }
    }
    return false
}

checkStart(line)
{
    instanceSpawnLines := ["HeistDungeon9"
        ,"HeistMansion9"
        ,"HeistRobotTunnels9"
        ,"HeistCourts9_"
        ,"HeistSewers9"
        ,"HeistLibrary9"
        ,"HeistReliquary9"
        ,"HeistMines9"
        ,"HeistBunker9"]
    return checkLineHas(line, instanceSpawnLines)
}

checkCompleted(line)
{
    return InStr(line, "HeistHub", true)
}
checkDied(line)
{
    return InStr(line, "has been slain.", true)
}

checkGrab(line)
{
    grabLines := ["Gianna, the Master of Disguise: Perfect! Now for the climax!"
        ,"Gianna, the Master of Disguise: Good! Now rush to the exit!"
        ,"Gianna, the Master of Disguise: No time for accolades! Go!"
        ,"Gianna, the Master of Disguise: Hope you're not waiting for applause!"
        ,"Huck, the Soldier: Great! Mission ain't over yet!"
        ,"Huck, the Soldier: Time to retreat!"
        ,"Huck, the Soldier: Move to the exit!"
        ,"Huck, the Soldier: Got it? Then move!"
        ,"Tibbs, the Giant: Go! Go!!"
        ,"Tibbs, the Giant: Let's Go!"
        ,"Tibbs, the Giant: Move, or we're dead!"
        ,"Tibbs, the Giant: Great! We have to move!"
        ,"Vinderi, the Dismantler: Get a move on!"
        ,"Vinderi, the Dismantler: That's it! Now out! Out!"
        ,"Vinderi, the Dismantler: Got it? Then move!"
        ,"Vinderi, the Dismantler: Go on then! Make a path!"
        ,"Tullina, the Catburglar: Great! Let's go!"
        ,"Tullina, the Catburglar: Go! Go! Go!"
        ,"Tullina, the Catburglar: Back out! Just gotta survive..."
        ,"Tullina, the Catburglar: Good! Time to leave!"
        ,"Nenet, the Scout: Good, go!"
        ,"Nenet, the Scout: Run!"
        ,"Nenet, the Scout: Escape!"
        ,"Nenet, the Scout: Move!"
        ,"Isla, the Engineer: I recommend flight!"
        ,"Isla, the Engineer: Time to flee!"
        ,"Isla, the Engineer: Let's run!"
        ,"Isla, the Engineer: Got it? Let's go!"
        ,"Karst, the Lockpick: Good! Go!"
        ,"Karst, the Lockpick: Mooooove!"
        ,"Karst, the Lockpick: Run, rook! Run!"
        ,"Karst, the Lockpick: Let's scarper!"
        ,"Niles, the Interrogator: Let's hope it's not too late!"
        ,"Niles, the Interrogator: Where's the exit?!"
        ,"Niles, the Interrogator: Let's find Adiyah!"
        ,"Niles, the Interrogator: There must be some kind of way out of here!"]
    
    return checkLineHas(line, grabLines)
}

checkRogues(line)
{
    global
    local giannaLines := ["Gianna, the Master of Disguise: I know set dressing when I see it."
        ,"Gianna, the Master of Disguise: They're hiding something. Look."
        ,"Gianna, the Master of Disguise: Those are props. Something's amiss."
        ,"Gianna, the Master of Disguise: Something about this doesn't ring true... Hmm."
        ,"Gianna, the Master of Disguise: It'd be easier to see with proper stage lighting..."
        ,"Gianna, the Master of Disguise: All that time squinting at cue cards has trained me for this."
        ,"Gianna, the Master of Disguise: Back in line, soldier! I will inspect!"
        ,"Gianna, the Master of Disguise: Did I say you could speak? Let me do this."
        ,"Gianna, the Master of Disguise: Quiet. ... See? Nothing. I'll show you."
        ,"Gianna, the Master of Disguise: Are you drunk, soldier?! There's nothing on the other side."
        ,"Gianna, the Master of Disguise: Stay in formation! This is a drill!"
        ,"Gianna, the Master of Disguise: Obey your orders! I'll take point!"
        ,"Gianna, the Master of Disguise: I didn't hear nothin', but let's see."
        ,"Gianna, the Master of Disguise: Oi, keep it down. Gettin' each other spooked. Here, I'll prove it."
        ,"Gianna, the Master of Disguise: Don't be so paranoid. Look, nothing's here..."
        ,"Gianna, the Master of Disguise: You're just drunk, mate. Watch, it'll be empty."
        ,"Gianna, the Master of Disguise: Probably just the rats. Afraid of rats? Let's find out!"
        ,"Gianna, the Master of Disguise: Nah, you're just losin' it. How could anything be here?"
        ,"Gianna, the Master of Disguise: Ease off the elixir. Nothing is here. Observe."
        ,"Gianna, the Master of Disguise: The fumes are affecting your judgement. I shall prove it."
        ,"Gianna, the Master of Disguise: Likely a mere apparition, but I'll make sure."
        ,"Gianna, the Master of Disguise: Perhaps you should rest. I'll check for you."
        ,"Gianna, the Master of Disguise: A hallucinatory phenomena. Anything you see is, as well."
        ,"Gianna, the Master of Disguise: Hearing things is a known side effect, but just to be sure..."
        ,"Gianna, the Master of Disguise: My focus is elsewhere."
        ,"Gianna, the Master of Disguise: I need to finish this first."
        ,"Gianna, the Master of Disguise: You can't rush a good performance."
        ,"Gianna, the Master of Disguise: Good work takes time."
        ,"Gianna, the Master of Disguise: Please try to be patient."
        ,"Gianna, the Master of Disguise: Protect your female lead."
        ,"Gianna, the Master of Disguise: Hey, you're hindering a great performance."
        ,"Gianna, the Master of Disguise: So distracting and awful."
        ,"Gianna, the Master of Disguise: Mean. Mean mean mean."
        ,"Gianna, the Master of Disguise: We've got trouble."
        ,"Gianna, the Master of Disguise: We're just looking around, I swear!"
        ,"Gianna, the Master of Disguise: Exile? Need you for this!"
        ,"Gianna, the Master of Disguise: Guards! Weapons up!"
        ,"Gianna, the Master of Disguise: Enemies heading our way!"
        ,"Gianna, the Master of Disguise: What an anticlimax."
        ,"Gianna, the Master of Disguise: Should've rehearsed more."
        ,"Gianna, the Master of Disguise: Saw that ending coming a mile away."
        ,"Gianna, the Master of Disguise: What, no plot twist?"
        ,"Gianna, the Master of Disguise: Always knew I'd knock 'em dead."
        ,"Gianna, the Master of Disguise: Oooh, that's soooo pretty."
        ,"Gianna, the Master of Disguise: That gives me an idea for a character."
        ,"Gianna, the Master of Disguise: Really good find."
        ,"Gianna, the Master of Disguise: Finders keepers, eh?"
        ,"Gianna, the Master of Disguise: You've a keen eye for pretty little things, don't you?"
        ,"Gianna, the Master of Disguise: Shh. We don't want an audience."
        ,"Gianna, the Master of Disguise: Keep it down. There's a lot left to do."
        ,"Gianna, the Master of Disguise: Quiet, or we'll have to end early."
        ,"Gianna, the Master of Disguise: This is far more tense than I like."
        ,"Gianna, the Master of Disguise: That's our cue to leave!"
        ,"Gianna, the Master of Disguise: Head for the exit!"
        ,"Gianna, the Master of Disguise: Make a run for it!"
        ,"Gianna, the Master of Disguise: Well, now we improvise!"
        ,"Gianna, the Master of Disguise: So much for the plan! Run!"
        ,"Gianna, the Master of Disguise: That's not good! We need to rush!"
        ,"Gianna, the Master of Disguise: And there, before her, was everything she wanted..."
        ,"Gianna, the Master of Disguise: They were so close, they could almost taste it."
        ,"Gianna, the Master of Disguise: In most plays, this is where I'd double-cross you. ... I-... I'm not going to double-cross you."
        ,"Gianna, the Master of Disguise: This is what we're here for. Go on."
        ,"Gianna, the Master of Disguise: Well? Don't keep the audience waiting!"
        ,"Gianna, the Master of Disguise: This is the part where you would double-cross me. Please don't."
        ,"Gianna, the Master of Disguise: Now all that's left is to head for the exit."
        ,"Gianna, the Master of Disguise: That's a relief. I always expect a trap for some reason."
        ,"Gianna, the Master of Disguise: People have strange taste, don't you think?"
        ,"Gianna, the Master of Disguise: Wait, what's that!?"
        ,"Gianna, the Master of Disguise: Look! There! No, there!"
        ,"Gianna, the Master of Disguise: They've tried to hide something!"
        ,"Gianna, the Master of Disguise: I know there's something wrong here, just need a bit of time!"
        ,"Gianna, the Master of Disguise: A lot of work went into hiding something here!"
        ,"Gianna, the Master of Disguise: Some convincing fakes here! What are they hiding!?"
        ,"Gianna, the Master of Disguise: Open it! Let them through! Oh, I'll do it!"
        ,"Gianna, the Master of Disguise: Stand back! I'll take them on single handedly!"
        ,"Gianna, the Master of Disguise: Make way! I must let the reinforcements in!"
        ,"Gianna, the Master of Disguise: Give passage! I have a plan!"
        ,"Gianna, the Master of Disguise: They're with us!"
        ,"Gianna, the Master of Disguise: I'll open the passage, and you take them alive!"
        ,"Gianna, the Master of Disguise: I need an understudy!"
        ,"Gianna, the Master of Disguise: Out of my face! Now!"
        ,"Gianna, the Master of Disguise: Do something or this will take forever!"
        ,"Gianna, the Master of Disguise: Too rough! Far too rough!"
        ,"Gianna, the Master of Disguise: Security incoming!"
        ,"Gianna, the Master of Disguise: Let us through, or face your death!"
        ,"Gianna, the Master of Disguise: This is your final scene!"
        ,"Gianna, the Master of Disguise: They just keep coming!"
        ,"Gianna, the Master of Disguise: Leave us alone!"
        ,"Gianna, the Master of Disguise: No second act!"
        ,"Gianna, the Master of Disguise: It's like they forget they're the villains! Wait... Are they the villains? No, yeah, they're the villains."
        ,"Gianna, the Master of Disguise: Don't stop moving!"
        ,"Gianna, the Master of Disguise: Keep it up, Exile!"
        ,"Gianna, the Master of Disguise: Spectacular! Keep going!"]
    local vinderiLines
    vinderiLines := ["Vinderi, the Dismantler: Huh. Not too hard."
        ,"Vinderi, the Dismantler: Cheap piece of junk anyway."
        ,"Vinderi, the Dismantler: Let's pop this little sucker open."
        ,"Vinderi, the Dismantler: Hmm, tricky, but not impossible."
        ,"Vinderi, the Dismantler: Haven't come across this make before. Well, let's give it a go."
        ,"Vinderi, the Dismantler: Ooh. Solidly built. Open up to me. It's okay, be vulnerable."
        ,"Vinderi, the Dismantler: Now, how do I work this thing again?"
        ,"Vinderi, the Dismantler: Con-fangled dang contraptions."
        ,"Vinderi, the Dismantler: You don't expect me to jump, do you?"
        ,"Vinderi, the Dismantler: I have the thing for this somewhere..."
        ,"Vinderi, the Dismantler: I did bring the thing. Did I? Thought I did..."
        ,"Vinderi, the Dismantler: I was hoping I wouldn't have to remember how to use this blasted thing"
        ,"Vinderi, the Dismantler: Ah, clever. Not clever enough, but still."
        ,"Vinderi, the Dismantler: Not the worst trap. Not the best, but not the worst."
        ,"Vinderi, the Dismantler: Just pop this spring and..."
        ,"Vinderi, the Dismantler: Oh, those clever bastards. Hmm. Hmmmmmm."
        ,"Vinderi, the Dismantler: Easy pe--...oh. Oh no. Oh? Oh."
        ,"Vinderi, the Dismantler: Huh. Looks like a twist on a Maloney design."
        ,"Vinderi, the Dismantler: Hee hee hee hee hee!'"
        ,"Vinderi, the Dismantler: Fun fun fun!"
        ,"Vinderi, the Dismantler: Hold onto your butts!"
        ,"Vinderi, the Dismantler: This needs a BIG one."
        ,"Vinderi, the Dismantler: Yes, yes... I have just the thing!"
        ,"Vinderi, the Dismantler: I've been saving this one just for you."
        ,"Vinderi, the Dismantler: Eh? It can wait."
        ,"Vinderi, the Dismantler: You blind? Or just daft?"
        ,"Vinderi, the Dismantler: Don't rush me."
        ,"Vinderi, the Dismantler: Oh, sure, rush the guy with the bombs."
        ,"Vinderi, the Dismantler: ""It was all going so well, then Vinderi blew us all up because I got impatient."""
        ,"Vinderi, the Dismantler: Pick on someone your own age."
        ,"Vinderi, the Dismantler: Moron. Moronic moron."
        ,"Vinderi, the Dismantler: Stop hitting me, you nitwit. I have BOMBS."
        ,"Vinderi, the Dismantler: Idiot's trying to blow us both up!"
        ,"Vinderi, the Dismantler: I'm old, but you'll still die sooner!"
        ,"Vinderi, the Dismantler: Quick, get 'em."
        ,"Vinderi, the Dismantler: We've been spotted!"
        ,"Vinderi, the Dismantler: We have company!"
        ,"Vinderi, the Dismantler: Oi, incoming."
        ,"Vinderi, the Dismantler: Feel so young again."
        ,"Vinderi, the Dismantler: Whew, that gets the ol' heart racing."
        ,"Vinderi, the Dismantler: Tougher than I look, eh?"
        ,"Vinderi, the Dismantler: Experience wins."
        ,"Vinderi, the Dismantler: Don't underestimate me."
        ,"Vinderi, the Dismantler: Well, well!"
        ,"Vinderi, the Dismantler: That, my friend, is very expensive looking."
        ,"Vinderi, the Dismantler: She's a beaut."
        ,"Vinderi, the Dismantler: In my younger days I'd fight you for that."
        ,"Vinderi, the Dismantler: Bit of advice: keep that little find to yourself."
        ,"Vinderi, the Dismantler: I think we're pushing it."
        ,"Vinderi, the Dismantler: We're going to get found out if we're not careful."
        ,"Vinderi, the Dismantler: When even I think we're too loud, that's a problem."
        ,"Vinderi, the Dismantler: Cutting it close."
        ,"Vinderi, the Dismantler: We have to leave!"
        ,"Vinderi, the Dismantler: Let's go! Let's go!"
        ,"Vinderi, the Dismantler: Storm the exit!"
        ,"Vinderi, the Dismantler: Oh no, OH NO!"
        ,"Vinderi, the Dismantler: That noise? That is not a good noise."
        ,"Vinderi, the Dismantler: I know that sound. That's a bad sound."
        ,"Vinderi, the Dismantler: There she is."
        ,"Vinderi, the Dismantler: Well, go on then. That's what we're here for."
        ,"Vinderi, the Dismantler: That's what we're after, right?"
        ,"Vinderi, the Dismantler: We've made it this far. Why stop now?"
        ,"Vinderi, the Dismantler: Pride cometh before the alarm."
        ,"Vinderi, the Dismantler: And now we run."
        ,"Vinderi, the Dismantler: Come on, legs, don't fail me now."
        ,"Vinderi, the Dismantler: Great! ...How do we get out of here again?"
        ,"Vinderi, the Dismantler: How about you get us out of here, huh?"
        ,"Vinderi, the Dismantler: You sure?! Okay...!"
        ,"Vinderi, the Dismantler: Really? Now?!"
        ,"Vinderi, the Dismantler: Gods, you're serious...!"
        ,"Vinderi, the Dismantler: ""Vinderi, you're not busy running for your life are you?!"""
        ,"Vinderi, the Dismantler: You're insane, you know that, right?!"
        ,"Vinderi, the Dismantler: I don't work well under pressure!"
        ,"Vinderi, the Dismantler: Where's the blasted thing!?"
        ,"Vinderi, the Dismantler: How in the--... oh! Found it!"
        ,"Vinderi, the Dismantler: Go, go you stupid-...!"
        ,"Vinderi, the Dismantler: You have the thing!? Wait, I have the thing!"
        ,"Vinderi, the Dismantler: Ah! I've got the thing for this! Here we go--no, that's not it. AH! Here we go!"
        ,"Vinderi, the Dismantler: A gap! I have just the tool for this. Somewhere. Did I drop it? Ha! I was holding it! Don't you just hate that?!"
        ,"Vinderi, the Dismantler: This is meant to be DELICATE work!"
        ,"Vinderi, the Dismantler: The whole place is a damnable death trap!"
        ,"Vinderi, the Dismantler: Wait! This thing's rigged to kill us!"
        ,"Vinderi, the Dismantler: Gods! You were planning to blunder into this thing!"
        ,"Vinderi, the Dismantler: Trap! Trap! Stop! There's a trap! A trap!"
        ,"Vinderi, the Dismantler: This is exactly the sort of thing we should have handled earlier!"
        ,"Vinderi, the Dismantler: Can't even take the time to enjoy this!"
        ,"Vinderi, the Dismantler: I hate everything about this!"
        ,"Vinderi, the Dismantler: If I die, I hope this blows you up too!"
        ,"Vinderi, the Dismantler: Gods, these are NOT ideal conditions for handling explosive materials!"
        ,"Vinderi, the Dismantler: I wanted to save this one for a special occasion. You owe me a new bomb!"
        ,"Vinderi, the Dismantler: You've lost the plot!"
        ,"Vinderi, the Dismantler: I don't have a twin you know! He's long dead!!"
        ,"Vinderi, the Dismantler: What!? Now!?"
        ,"Vinderi, the Dismantler: I. Am. Busy!"
        ,"Vinderi, the Dismantler: I'm too old for this!"
        ,"Vinderi, the Dismantler: Old man under attack!"
        ,"Vinderi, the Dismantler: Elder abuse!"
        ,"Vinderi, the Dismantler: Not like this! Not like this!"
        ,"Vinderi, the Dismantler: Help! I'm too young to die!"
        ,"Vinderi, the Dismantler: They just keep coming!"
        ,"Vinderi, the Dismantler: To arms!"
        ,"Vinderi, the Dismantler: Ready yourselves!"
        ,"Vinderi, the Dismantler: Fight your way out!"
        ,"Vinderi, the Dismantler: Out of the way!"
        ,"Vinderi, the Dismantler: Gods that was satisfying!"
        ,"Vinderi, the Dismantler: Can't celebrate yet!"
        ,"Vinderi, the Dismantler: Just keep moving!"
        ,"Vinderi, the Dismantler: Any more? Huh!?"
        ,"Vinderi, the Dismantler: Old, but strong!"
        ,"Vinderi, the Dismantler: Why are you still grabbing things!?"
        ,"Vinderi, the Dismantler: Can't use it if you're dead!"
        ,"Vinderi, the Dismantler: Focus on escaping!"
        ,"Vinderi, the Dismantler: Attention span of a toddler!"
        ,"Vinderi, the Dismantler: Great, now you got more loot than brains!"
        ,"Vinderi, the Dismantler: Can't believe it, that's it!"
        ,"Vinderi, the Dismantler: That's what we're after!"
        ,"Vinderi, the Dismantler: There it is! What are you waiting for?!"
        ,"Vinderi, the Dismantler: Get it! Get it now!"
        ,"Vinderi, the Dismantler: If you don't get it now, you don't get it at all!"
        ,"Vinderi, the Dismantler: Get a move on!"
        ,"Vinderi, the Dismantler: That's it! Now out! Out!"
        ,"Vinderi, the Dismantler: Got it? Then move!"
        ,"Vinderi, the Dismantler: Go on then! Make a path!"]
    local karstLines
    karstLines := ["Karst, the Lockpick: Easy."
        ,"Karst, the Lockpick: Blink and you'll miss it."
        ,"Karst, the Lockpick: This'll be quick."
        ,"Karst, the Lockpick: Not quick, but not hard."
        ,"Karst, the Lockpick: That's what I'm here for."
        ,"Karst, the Lockpick: Shouldn't be a problem."
        ,"Karst, the Lockpick: I'll take a look."
        ,"Karst, the Lockpick: What are you hiding..."
        ,"Karst, the Lockpick: Something's not right..."
        ,"Karst, the Lockpick: Let's see... anything standing out?"
        ,"Karst, the Lockpick: What do we have here?"
        ,"Karst, the Lockpick: They're hiding something. I know it."
        ,"Karst, the Lockpick: Bit preoccupied."
        ,"Karst, the Lockpick: You'll have to wait."
        ,"Karst, the Lockpick: Got my hands full here."
        ,"Karst, the Lockpick: You blind? I'm busy."
        ,"Karst, the Lockpick: Trying to concentrate on something else."
        ,"Karst, the Lockpick: Oi, watch the hands!"
        ,"Karst, the Lockpick: Can't work while I'm gettin' hit."
        ,"Karst, the Lockpick: Any chance you could stop hitting me?"
        ,"Karst, the Lockpick: Piss off, ya shite."
        ,"Karst, the Lockpick: Let you get this one, yeah?"
        ,"Karst, the Lockpick: Who put you in a bad mood?"
        ,"Karst, the Lockpick: Nah, go on, you got 'em."
        ,"Karst, the Lockpick: Quick, before they make too much noise."
        ,"Karst, the Lockpick: We got company."
        ,"Karst, the Lockpick: Incoming."
        ,"Karst, the Lockpick: Too easy."
        ,"Karst, the Lockpick: Yeah. Yeeaaaah!"
        ,"Karst, the Lockpick: Wasn't worth it, was it?"
        ,"Karst, the Lockpick: Should've stayed out of it."
        ,"Karst, the Lockpick: I got the best of ya."
        ,"Karst, the Lockpick: If you don't want it, I'll take it."
        ,"Karst, the Lockpick: You sure you want that?"
        ,"Karst, the Lockpick: Ehh, reckon I'll find something better."
        ,"Karst, the Lockpick: Good. You take that."
        ,"Karst, the Lockpick: Plenty more where that came from, I reckon."
        ,"Karst, the Lockpick: Shh! Shut it."
        ,"Karst, the Lockpick: Keep it down, or else."
        ,"Karst, the Lockpick: You trying to get us caught?"
        ,"Karst, the Lockpick: Might need to bail soon."
        ,"Karst, the Lockpick: Oh boy, this is gonna get messy."
        ,"Karst, the Lockpick: Don't fail me now, rookie."
        ,"Karst, the Lockpick: Let's make our escape."
        ,"Karst, the Lockpick: Got us here safe 'n' sound, didn't I?"
        ,"Karst, the Lockpick: Got eyes on the prize."
        ,"Karst, the Lockpick: Real close now. Real close."
        ,"Karst, the Lockpick: Almost there. Don't screw it up."
        ,"Karst, the Lockpick: I think this is what we're here for."
        ,"Karst, the Lockpick: Tuck it away somewhere safe. We gotta move quick."
        ,"Karst, the Lockpick: Aw, I wanted to hold it. Fine. Whatever. Let's just go."
        ,"Karst, the Lockpick: Is it just me or is this as good as it gets?"
        ,"Karst, the Lockpick: Job done, right? Out we go."
        ,"Karst, the Lockpick: On it!"
        ,"Karst, the Lockpick: Yeah, I know!"
        ,"Karst, the Lockpick: Easy!"
        ,"Karst, the Lockpick: Just keep 'em off me!"
        ,"Karst, the Lockpick: I'll try to make it quick!"
        ,"Karst, the Lockpick: You do your job, I'll do mine!"
        ,"Karst, the Lockpick: Focus, Karst! Focus!"
        ,"Karst, the Lockpick: Nothing's--... There!"
        ,"Karst, the Lockpick: Ehh... Errrr... Eh?!"
        ,"Karst, the Lockpick: I can't see--... wait, what's that!?"
        ,"Karst, the Lockpick: Horrible time to just be standing 'round!"
        ,"Karst, the Lockpick: Something... Something... Gotta be something."
        ,"Karst, the Lockpick: Lend a hand, rookie!"
        ,"Karst, the Lockpick: Piss! Off!"
        ,"Karst, the Lockpick: Oi! Get!"
        ,"Karst, the Lockpick: What'd I do to you!?"
        ,"Karst, the Lockpick: This lot don't look friendly!"
        ,"Karst, the Lockpick: Oh, no no no no!"
        ,"Karst, the Lockpick: Rookie!? ROOK!?"
        ,"Karst, the Lockpick: Don't make me hurt you!"
        ,"Karst, the Lockpick: I'll fight you! I'll bloody do it, mate!"
        ,"Karst, the Lockpick: Keep moving!"
        ,"Karst, the Lockpick: Yeah! Yeaaaaaah!"
        ,"Karst, the Lockpick: Good! Don't slow down!"
        ,"Karst, the Lockpick: Dead now, ain't ya!"
        ,"Karst, the Lockpick: Not even close, mate!"
        ,"Karst, the Lockpick: Is lootin' still a priority!?"
        ,"Karst, the Lockpick: I get it, but is now the best time!?"
        ,"Karst, the Lockpick: Yeah, okay, I wouldn't have let that one go either!"
        ,"Karst, the Lockpick: Good nab, but let's go!"
        ,"Karst, the Lockpick: I better not die because you needed that!"
        ,"Karst, the Lockpick: Not done yet! Grab it!"
        ,"Karst, the Lockpick: Get the bloody thing and let's move!"
        ,"Karst, the Lockpick: Go get it, Rookie!"
        ,"Karst, the Lockpick: Pocket the goods! We gotta go!"
        ,"Karst, the Lockpick: Time's running out Rook!"
        ,"Karst, the Lockpick: Good! Go!"
        ,"Karst, the Lockpick: Mooooove!"
        ,"Karst, the Lockpick: Run, rook! Run!"
        ,"Karst, the Lockpick: Let's scarper!"]
    local tullinaLines
    tullinaLines := ["Tullina, the Catburglar: Nice and easy..."
        ,"Tullina, the Catburglar: Not too challenging..."
        ,"Tullina, the Catburglar: I'll handle it."
        ,"Tullina, the Catburglar: I'm not charging you enough."
        ,"Tullina, the Catburglar: Okay, Tullina, just like you practised."
        ,"Tullina, the Catburglar: Careful... Careful..."
        ,"Tullina, the Catburglar: I see what they've done here..."
        ,"Tullina, the Catburglar: Hmph. Who falls for this?"
        ,"Tullina, the Catburglar: Huh. Ah. I see."
        ,"Tullina, the Catburglar: Hmm. Yes. Devious. Very devious."
        ,"Tullina, the Catburglar: What an ingenious little ploy."
        ,"Tullina, the Catburglar: Clever. Almost... too clever. Almost."
        ,"Tullina, the Catburglar: I'll get us in there."
        ,"Tullina, the Catburglar: Let's see what you're hiding."
        ,"Tullina, the Catburglar: I can unlock this."
        ,"Tullina, the Catburglar: This might take some time, okay?"
        ,"Tullina, the Catburglar: I can do it, but it won't be quick."
        ,"Tullina, the Catburglar: Sure. Just be patient."
        ,"Tullina, the Catburglar: Don't be impatient."
        ,"Tullina, the Catburglar: I'm somewhat preoccupied."
        ,"Tullina, the Catburglar: Perhaps you should've planned this better."
        ,"Tullina, the Catburglar: I can't be in two places at once."
        ,"Tullina, the Catburglar: Wait. I'm busy."
        ,"Tullina, the Catburglar: If I wasn't busy you'd be dead."
        ,"Tullina, the Catburglar: Get them off me. Now."
        ,"Tullina, the Catburglar: I can't work while I'm being attacked."
        ,"Tullina, the Catburglar: You will regret this."
        ,"Tullina, the Catburglar: Security has spotted us."
        ,"Tullina, the Catburglar: We've got a fight on our hands."
        ,"Tullina, the Catburglar: You want to dance? Let's dance."
        ,"Tullina, the Catburglar: No witnesses."
        ,"Tullina, the Catburglar: Let's take them out."
        ,"Tullina, the Catburglar: Back to work."
        ,"Tullina, the Catburglar: No. Witnesses."
        ,"Tullina, the Catburglar: Good. Now, focus."
        ,"Tullina, the Catburglar: We have a job to do."
        ,"Tullina, the Catburglar: No more distractions."
        ,"Tullina, the Catburglar: A worthy prize."
        ,"Tullina, the Catburglar: That's why we do this."
        ,"Tullina, the Catburglar: Good find, but don't lose focus."
        ,"Tullina, the Catburglar: Well, I've taken worse!"
        ,"Tullina, the Catburglar: Not bad. Not bad at all."
        ,"Tullina, the Catburglar: We need to be careful."
        ,"Tullina, the Catburglar: We're pushing our luck now."
        ,"Tullina, the Catburglar: Clumsy work is going to get us caught."
        ,"Tullina, the Catburglar: Messy. I don't like where this is headed."
        ,"Tullina, the Catburglar: Head for the exit. Quick as possible!"
        ,"Tullina, the Catburglar: Time to leave! Come on!"
        ,"Tullina, the Catburglar: Now? Now we run!"
        ,"Tullina, the Catburglar: Damn. Should've been more careful."
        ,"Tullina, the Catburglar: We've screwed this up. Time to leave!"
        ,"Tullina, the Catburglar: Ugh, what a mess. What an absolute mess."
        ,"Tullina, the Catburglar: We're here, but it isn't over yet."
        ,"Tullina, the Catburglar: Good. Now, take it and get ready to run."
        ,"Tullina, the Catburglar: Ready? This is where it gets hairy."
        ,"Tullina, the Catburglar: Fun part's almost over."
        ,"Tullina, the Catburglar: That's the mark. You got it?"
        ,"Tullina, the Catburglar: Good. Very good."
        ,"Tullina, the Catburglar: Safely tucked away? Good."
        ,"Tullina, the Catburglar: Don't get overconfident. We're not done yet."
        ,"Tullina, the Catburglar: Now we've got their attention."
        ,"Tullina, the Catburglar: Just get it done."
        ,"Tullina, the Catburglar: I'm on it!"
        ,"Tullina, the Catburglar: Power through, Tullina!"
        ,"Tullina, the Catburglar: Now? So unprofessional!"
        ,"Tullina, the Catburglar: This is what you've been training for!"
        ,"Tullina, the Catburglar: Fine, but you should know I hold grudges!"
        ,"Tullina, the Catburglar: Right, what's the quickest--... Ah!"
        ,"Tullina, the Catburglar: Lucky it's straightforward!"
        ,"Tullina, the Catburglar: I think I've got this one figured out!"
        ,"Tullina, the Catburglar: Even without this racket, it'd take me a while...!"
        ,"Tullina, the Catburglar: I'll be as quick as I can, but that still won't be quick."
        ,"Tullina, the Catburglar: Wish we'd sorted this before we had to run!"
        ,"Tullina, the Catburglar: Fine. Fine!"
        ,"Tullina, the Catburglar: I've got this one!"
        ,"Tullina, the Catburglar: On it!"
        ,"Tullina, the Catburglar: This is going to take some time!"
        ,"Tullina, the Catburglar: Just keep us safe while I work!"
        ,"Tullina, the Catburglar: You just make sure we're all still alive when I'm done."
        ,"Tullina, the Catburglar: Testing my patience!"
        ,"Tullina, the Catburglar: Make up your mind!"
        ,"Tullina, the Catburglar: Not now, you--... Not now!"
        ,"Tullina, the Catburglar: Really?! Don't test me!"
        ,"Tullina, the Catburglar: Not now! This mess is on you!"
        ,"Tullina, the Catburglar: I'm under attack!"
        ,"Tullina, the Catburglar: Can't work with this harassment!"
        ,"Tullina, the Catburglar: Where's my protection!?"
        ,"Tullina, the Catburglar: Hey! I need assistance!"
        ,"Tullina, the Catburglar: Out of our way!"
        ,"Tullina, the Catburglar: Let us through or die!"
        ,"Tullina, the Catburglar: No witnesses!"
        ,"Tullina, the Catburglar: You must not value your lives!"
        ,"Tullina, the Catburglar: Guards incoming!"
        ,"Tullina, the Catburglar: Move! Move!"
        ,"Tullina, the Catburglar: Good! Keep up the momentum!"
        ,"Tullina, the Catburglar: Very good! Stay focused!"
        ,"Tullina, the Catburglar: Guards down! Let's go!"
        ,"Tullina, the Catburglar: All clear!"
        ,"Tullina, the Catburglar: If we die because you slowed us down, I'll kill you!"
        ,"Tullina, the Catburglar: Don't get too greedy!"
        ,"Tullina, the Catburglar: Fine, but we have to keep moving!"
        ,"Tullina, the Catburglar: You're pushing it! Not in a good way!"
        ,"Tullina, the Catburglar: The stealing was meant to happen earlier!"
        ,"Tullina, the Catburglar: Made it in! Quick!"
        ,"Tullina, the Catburglar: Grab it and let's go!"
        ,"Tullina, the Catburglar: There's our target! Hurry!"
        ,"Tullina, the Catburglar: We're not done yet! Grab it!"
        ,"Tullina, the Catburglar: Get it! Now! What a mess..."
        ,"Tullina, the Catburglar: Great! Let's go!"
        ,"Tullina, the Catburglar: Go! Go! Go!"
        ,"Tullina, the Catburglar: Back out! Just gotta survive..."
        ,"Tullina, the Catburglar: Good! Time to leave!"]
    local tibbsLines
    tibbsLines := ["Tibbs, the Giant: Right."
        ,"Tibbs, the Giant: On it, boss."
        ,"Tibbs, the Giant: Easy."
        ,"Tibbs, the Giant: Lemme jus' get this outta the way for ya."
        ,"Tibbs, the Giant: Won't be a jiff."
        ,"Tibbs, the Giant: Oh, I'm going to be sore tomorrow."
        ,"Tibbs, the Giant: Consider it gone."
        ,"Tibbs, the Giant: Oughta be quick."
        ,"Tibbs, the Giant: Looks fragile enough..."
        ,"Tibbs, the Giant: If it ain't broke, it will be..."
        ,"Tibbs, the Giant: This one might take a bit, but we'll get there."
        ,"Tibbs, the Giant: I think it'd look better in pieces too."
        ,"Tibbs, the Giant: One sec."
        ,"Tibbs, the Giant: In the middle of something here."
        ,"Tibbs, the Giant: Can it wait?"
        ,"Tibbs, the Giant: Mate, I'm busy."
        ,"Tibbs, the Giant: When I'm done with this, yeah?"
        ,"Tibbs, the Giant: Ugh! Little help here?"
        ,"Tibbs, the Giant: Oi, I'm getting hit!"
        ,"Tibbs, the Giant: Get the bastards off me!"
        ,"Tibbs, the Giant: Damn. Help!"
        ,"Tibbs, the Giant: Should've ignored the noise, mate."
        ,"Tibbs, the Giant: You ain't gonna like this."
        ,"Tibbs, the Giant: Heads up, we got trouble!"
        ,"Tibbs, the Giant: Hate this part of the job."
        ,"Tibbs, the Giant: You're gonna be sorry. Then I'm gonna be sorry."
        ,"Tibbs, the Giant: Right, well, carry on I guess."
        ,"Tibbs, the Giant: Good stuff."
        ,"Tibbs, the Giant: Least we ain't cleaning up."
        ,"Tibbs, the Giant: Keep it quick and quiet."
        ,"Tibbs, the Giant: ...Sorry."
        ,"Tibbs, the Giant: Not too shabby, mate."
        ,"Tibbs, the Giant: Nice piece."
        ,"Tibbs, the Giant: Now who just leaves something like that lying around?"
        ,"Tibbs, the Giant: That is a keeper."
        ,"Tibbs, the Giant: Oh, know a girl who'd love that."
        ,"Tibbs, the Giant: We've gotta keep it down."
        ,"Tibbs, the Giant: I'm gettin' a bad feeling, mate."
        ,"Tibbs, the Giant: Reckon we're cutting it close now."
        ,"Tibbs, the Giant: Right, we gotta make tracks soon."
        ,"Tibbs, the Giant: Time to leave!"
        ,"Tibbs, the Giant: Let's start making tracks."
        ,"Tibbs, the Giant: There it is. Let's go!"
        ,"Tibbs, the Giant: Woah, mate, we gotta move!"
        ,"Tibbs, the Giant: Hear that?! Let's head out!"
        ,"Tibbs, the Giant: Now you've gone and done it."
        ,"Tibbs, the Giant: Think this might be what we're after."
        ,"Tibbs, the Giant: Ah, here it is."
        ,"Tibbs, the Giant: Right, let's nab it and go."
        ,"Tibbs, the Giant: Here we go. Make it quick."
        ,"Tibbs, the Giant: Gotta be in here somewhere."
        ,"Tibbs, the Giant: Got it? Good."
        ,"Tibbs, the Giant: Now let's get it back."
        ,"Tibbs, the Giant: Now we just gotta make it out alive!"
        ,"Tibbs, the Giant: Now for the hard part."
        ,"Tibbs, the Giant: Rarhgh!"
        ,"Tibbs, the Giant: Outa the way!"
        ,"Tibbs, the Giant: Huuurrrraagh"
        ,"Tibbs, the Giant: I. Am. Stressed!"
        ,"Tibbs, the Giant: I'll do my best, but damn!"
        ,"Tibbs, the Giant: I'm taking the longest, bubbliest damn bath after this!"
        ,"Tibbs, the Giant: Stand back!"
        ,"Tibbs, the Giant: Hope this works!"
        ,"Tibbs, the Giant: Ere we go!"
        ,"Tibbs, the Giant: This is a bloody ruckus!"
        ,"Tibbs, the Giant: This one might hurt."
        ,"Tibbs, the Giant: This is gonna leave a mark!"
        ,"Tibbs, the Giant: Bit busy!"
        ,"Tibbs, the Giant: Got my hands full!"
        ,"Tibbs, the Giant: Now!? WHY NOW!?"
        ,"Tibbs, the Giant: NO! LATER!"
        ,"Tibbs, the Giant: Not. Now!"
        ,"Tibbs, the Giant: I can't work under these conditions!"
        ,"Tibbs, the Giant: Help or we ain't moving!"
        ,"Tibbs, the Giant: Quit hittin' me!"
        ,"Tibbs, the Giant: Agh! Buzz off mate!"
        ,"Tibbs, the Giant: Comin' through!"
        ,"Tibbs, the Giant: Guess we're doin' this!"
        ,"Tibbs, the Giant: Ain't gonna be gentle!"
        ,"Tibbs, the Giant: Hate this part! Hate it!"
        ,"Tibbs, the Giant: ""Go on Tibbs, you're a big guy!"""
        ,"Tibbs, the Giant: Can we go?!"
        ,"Tibbs, the Giant: Part of the job. Part of the job."
        ,"Tibbs, the Giant: We had to, right!?"
        ,"Tibbs, the Giant: Should've just let us leave."
        ,"Tibbs, the Giant: Doesn't get any easier."
        ,"Tibbs, the Giant: Nice, but we gotta move!"
        ,"Tibbs, the Giant: Better be worth the delay, mate!"
        ,"Tibbs, the Giant: What, you need more?!"
        ,"Tibbs, the Giant: Your greed better not get us killed!"
        ,"Tibbs, the Giant: You good now?!"
        ,"Tibbs, the Giant: This is it!"
        ,"Tibbs, the Giant: We made it! Hurry!"
        ,"Tibbs, the Giant: Quick, we don't have long!"
        ,"Tibbs, the Giant: That's our mark! Grab it and go!"
        ,"Tibbs, the Giant: Wait, that's the target!"
        ,"Tibbs, the Giant: Go! Go!!"
        ,"Tibbs, the Giant: Let's Go!"
        ,"Tibbs, the Giant: Move, or we're dead!"
        ,"Tibbs, the Giant: Great! We have to move!"]
    local nilesLines
    nilesLines := ["Niles, the Interrogator: I shall make it so."
        ,"Niles, the Interrogator: Of course."
        ,"Niles, the Interrogator: Focusing..."
        ,"Niles, the Interrogator: My mind shall dwarf theirs."
        ,"Niles, the Interrogator: I am a mental giant."
        ,"Niles, the Interrogator: Allow me to focus..."
        ,"Niles, the Interrogator: Right away!"
        ,"Niles, the Interrogator: I'll try to be quick!"
        ,"Niles, the Interrogator: Of course!"
        ,"Niles, the Interrogator: Mind control is a delicate art!"
        ,"Niles, the Interrogator: I'll be as quick as I can!"
        ,"Niles, the Interrogator: Uggggh, if I must."
        ,"Niles, the Interrogator: Easily fooled."
        ,"Niles, the Interrogator: Practiced lies, deceived eyes."
        ,"Niles, the Interrogator: Watch and learn."
        ,"Niles, the Interrogator: They'll never even suspect."
        ,"Niles, the Interrogator: This should be easy. Should be."
        ,"Niles, the Interrogator: Just another form of mind control."
        ,"Niles, the Interrogator: I'll try!"
        ,"Niles, the Interrogator: Fine!"
        ,"Niles, the Interrogator: Alright!"
        ,"Niles, the Interrogator: This is a mess!"
        ,"Niles, the Interrogator: This might still work!"
        ,"Niles, the Interrogator: Not a problem!"
        ,"Niles, the Interrogator: I've already got a task!"
        ,"Niles, the Interrogator: I can't really hear you."
        ,"Niles, the Interrogator: I'm busy..."
        ,"Niles, the Interrogator: Not yet!"
        ,"Niles, the Interrogator: You have no idea what you're doing, do you?"
        ,"Niles, the Interrogator: Buzz off, pest!"
        ,"Niles, the Interrogator: Not now!"
        ,"Niles, the Interrogator: I'm focusing!"
        ,"Niles, the Interrogator: Quit pestering me!"
        ,"Niles, the Interrogator: Grrrr!"
        ,"Niles, the Interrogator: Heretics!"
        ,"Niles, the Interrogator: Infidels!"
        ,"Niles, the Interrogator: That hurt!"
        ,"Niles, the Interrogator: Hey, stop it!"
        ,"Niles, the Interrogator: Yeowch!"
        ,"Niles, the Interrogator: Exile, save me!"
        ,"Niles, the Interrogator: I'm bleeding!"
        ,"Niles, the Interrogator: Stabbed AGAIN?"
        ,"Niles, the Interrogator: I {need} to {focus}!"
        ,"Niles, the Interrogator: Commence the bloody work."
        ,"Niles, the Interrogator: Time for a tussle."
        ,"Niles, the Interrogator: Torture quickened counts as combat."
        ,"Niles, the Interrogator: You can handle this, yes?"
        ,"Niles, the Interrogator: I really don't want to get stabbed again."
        ,"Niles, the Interrogator: You have chosen death!"
        ,"Niles, the Interrogator: I refuse to die here!"
        ,"Niles, the Interrogator: To battle!"
        ,"Niles, the Interrogator: Clash of arms!"
        ,"Niles, the Interrogator: Not today!"
        ,"Niles, the Interrogator: Mortal strength carries the day."
        ,"Niles, the Interrogator: Glad you're on my side."
        ,"Niles, the Interrogator: No afterlife for them. A shame."
        ,"Niles, the Interrogator: Thank God we survived. Wait, I didn't mean that!"
        ,"Niles, the Interrogator: I didn't get stabbed?"
        ,"Niles, the Interrogator: Well, glad that's over."
        ,"Niles, the Interrogator: All this gore reminds me of home."
        ,"Niles, the Interrogator: Keep going! Run!"
        ,"Niles, the Interrogator: We can't stop now!"
        ,"Niles, the Interrogator: What next?!"
        ,"Niles, the Interrogator: It would seem our luck has not yet run out!"
        ,"Niles, the Interrogator: Absolutely brutal."
        ,"Niles, the Interrogator: Lovely. Just lovely."
        ,"Niles, the Interrogator: Don't you owe me a few markers?"
        ,"Niles, the Interrogator: Avarice is not entirely without merit."
        ,"Niles, the Interrogator: Not all treasure is silver and gold."
        ,"Niles, the Interrogator: I'm unimpressed."
        ,"Niles, the Interrogator: Leave it, there are more important matters!"
        ,"Niles, the Interrogator: Are you seriously doing that right now?"
        ,"Niles, the Interrogator: Your avarice knows no bounds!"
        ,"Niles, the Interrogator: Pecuniary sloth!"
        ,"Niles, the Interrogator: Quit wasting time!"
        ,"Niles, the Interrogator: You do know we're about to get caught?"
        ,"Niles, the Interrogator: I sense suspicion. They may be on to us."
        ,"Niles, the Interrogator: To err is human, but one more mistake and we'll be ruined."
        ,"Niles, the Interrogator: They're about to notice us."
        ,"Niles, the Interrogator: Time to go, I take it?"
        ,"Niles, the Interrogator: This was part of the plan, right?"
        ,"Niles, the Interrogator: Was that supposed to happen?"
        ,"Niles, the Interrogator: Drat."
        ,"Niles, the Interrogator: Flee!"
        ,"Niles, the Interrogator: You've done it now!"
        ,"Niles, the Interrogator: The inner sanctum..."
        ,"Niles, the Interrogator: Do what you must."
        ,"Niles, the Interrogator: I half expected us not to make it this far."
        ,"Niles, the Interrogator: There may be traps. You go first."
        ,"Niles, the Interrogator: Time to make an acquisition."
        ,"Niles, the Interrogator: Hurry!"
        ,"Niles, the Interrogator: Don't waste time!"
        ,"Niles, the Interrogator: Move like your life depends upon it!"
        ,"Niles, the Interrogator: What are you waiting for?!"
        ,"Niles, the Interrogator: Go get it!"
        ,"Niles, the Interrogator: You've got it!"
        ,"Niles, the Interrogator: And without any divine aid!"
        ,"Niles, the Interrogator: Alright, then. We have it."
        ,"Niles, the Interrogator: Good, very good."
        ,"Niles, the Interrogator: Let's hope it's not too late!"
        ,"Niles, the Interrogator: Where's the exit?!"
        ,"Niles, the Interrogator: Let's find Adiyah!"
        ,"Niles, the Interrogator: There must be some kind of way out of here!"]
    local nenetLines
    nenetLines := ["Nenet, the Scout: I see."
        ,"Nenet, the Scout: It's quite clear to me."
        ,"Nenet, the Scout: Of course."
        ,"Nenet, the Scout: Allow me a moment to focus..."
        ,"Nenet, the Scout: Seeing sometimes relies on more than one's eyes."
        ,"Nenet, the Scout: Quiet, I'm listening..."
        ,"Nenet, the Scout: Indeed!"
        ,"Nenet, the Scout: Quickly, yes!"
        ,"Nenet, the Scout: Reporting!"
        ,"Nenet, the Scout: I'm trying to focus!"
        ,"Nenet, the Scout: Let me listen!"
        ,"Nenet, the Scout: Quickly!"
        ,"Nenet, the Scout: Sorry, I am busy."
        ,"Nenet, the Scout: I cannot just now."
        ,"Nenet, the Scout: I'll be with you in a moment."
        ,"Nenet, the Scout: I hear you, but cannot yet."
        ,"Nenet, the Scout: I am already tasked!"
        ,"Nenet, the Scout: Busy!"
        ,"Nenet, the Scout: I can't!"
        ,"Nenet, the Scout: I'm otherwise engaged!"
        ,"Nenet, the Scout: No time!"
        ,"Nenet, the Scout: I can't do that!"
        ,"Nenet, the Scout: I am under attack!"
        ,"Nenet, the Scout: I require aid!"
        ,"Nenet, the Scout: They've caught me!"
        ,"Nenet, the Scout: They have me!"
        ,"Nenet, the Scout: Help!"
        ,"Nenet, the Scout: Ouch!"
        ,"Nenet, the Scout: To me, quickly!"
        ,"Nenet, the Scout: Caught!"
        ,"Nenet, the Scout: I do not fear death."
        ,"Nenet, the Scout: So the clash comes."
        ,"Nenet, the Scout: So much for stealth."
        ,"Nenet, the Scout: Death, one way or another!"
        ,"Nenet, the Scout: Fight together and we shall overcome!"
        ,"Nenet, the Scout: We shall stand."
        ,"Nenet, the Scout: A fight, then."
        ,"Nenet, the Scout: Unite!"
        ,"Nenet, the Scout: Here they come!"
        ,"Nenet, the Scout: Clash!"
        ,"Nenet, the Scout: Today is not the end, then."
        ,"Nenet, the Scout: I knew we could do it."
        ,"Nenet, the Scout: Back to stealth."
        ,"Nenet, the Scout: Death... for them."
        ,"Nenet, the Scout: Together. Success."
        ,"Nenet, the Scout: Good. Move!"
        ,"Nenet, the Scout: Go!"
        ,"Nenet, the Scout: Thank you."
        ,"Nenet, the Scout: We must continue."
        ,"Nenet, the Scout: Good riddance."
        ,"Nenet, the Scout: Take what you can. Live for now."
        ,"Nenet, the Scout: Treasure for the taking."
        ,"Nenet, the Scout: I hope you will share that."
        ,"Nenet, the Scout: All that glitters."
        ,"Nenet, the Scout: More is better than less."
        ,"Nenet, the Scout: Is that wise?!"
        ,"Nenet, the Scout: Should we really delay like this?"
        ,"Nenet, the Scout: We must make haste!"
        ,"Nenet, the Scout: Treasure or life?"
        ,"Nenet, the Scout: We need to escape!"
        ,"Nenet, the Scout: We may be spotted soon."
        ,"Nenet, the Scout: We are treading too heavily."
        ,"Nenet, the Scout: We can ill afford any more mistakes."
        ,"Nenet, the Scout: They will catch on to our presence."
        ,"Nenet, the Scout: Swiftly, now."
        ,"Nenet, the Scout: As expected."
        ,"Nenet, the Scout: We should escape now."
        ,"Nenet, the Scout: We have been spotted!"
        ,"Nenet, the Scout: Too clumsy!"
        ,"Nenet, the Scout: They've seen us!"
        ,"Nenet, the Scout: Here we are, then."
        ,"Nenet, the Scout: Do you remember what to do?"
        ,"Nenet, the Scout: If you need help, I am here."
        ,"Nenet, the Scout: Exile, make your move."
        ,"Nenet, the Scout: We made it."
        ,"Nenet, the Scout: Make your move quickly!"
        ,"Nenet, the Scout: Clumsy but speedy, now!"
        ,"Nenet, the Scout: Get it done!"
        ,"Nenet, the Scout: Forward!"
        ,"Nenet, the Scout: Move like the wind!"
        ,"Nenet, the Scout: We have it!"
        ,"Nenet, the Scout: Very good."
        ,"Nenet, the Scout: It is done."
        ,"Nenet, the Scout: Ready?"
        ,"Nenet, the Scout: Good, go!"
        ,"Nenet, the Scout: Run!"
        ,"Nenet, the Scout: Escape!"
        ,"Nenet, the Scout: Move!"]
    local huckLines
    huckLines := ["Huck, the Soldier: Standard issue lock. Shouldn't be too difficult."
        ,"Huck, the Soldier: Trained on this exact kind."
        ,"Huck, the Soldier: Yessir."
        ,"Huck, the Soldier: Tricky one, but doable."
        ,"Huck, the Soldier: I'll do my damndest."
        ,"Huck, the Soldier: Ought to be able to open it."
        ,"Huck, the Soldier: Sir!"
        ,"Huck, the Soldier: Trained for this."
        ,"Huck, the Soldier: Not a problem."
        ,"Huck, the Soldier: Difficult, not impossible."
        ,"Huck, the Soldier: Leave it to me."
        ,"Huck, the Soldier: Looks heavy, but not too heavy."
        ,"Huck, the Soldier: Yessir."
        ,"Huck, the Soldier: Putting down a charge."
        ,"Huck, the Soldier: Lighting up."
        ,"Huck, the Soldier: Stand back, this won't be pretty."
        ,"Huck, the Soldier: Get to a safe distance"
        ,"Huck, the Soldier: Careful. Need to blow it up."
        ,"Huck, the Soldier: Currently following other orders."
        ,"Huck, the Soldier: One job at a time."
        ,"Huck, the Soldier: Once this task is complete."
        ,"Huck, the Soldier: I've got to finish this task first."
        ,"Huck, the Soldier: Other orders take priority."
        ,"Huck, the Soldier: I require backup."
        ,"Huck, the Soldier: I'm under attack."
        ,"Huck, the Soldier: Need help over here."
        ,"Huck, the Soldier: Can't finish my task like this."
        ,"Huck, the Soldier: Guards, incoming."
        ,"Huck, the Soldier: Security inbound."
        ,"Huck, the Soldier: Guards. Get in position."
        ,"Huck, the Soldier: Ready yourself for combat."
        ,"Huck, the Soldier: Got a fight on our hands."
        ,"Huck, the Soldier: All clear."
        ,"Huck, the Soldier: No more hostiles."
        ,"Huck, the Soldier: Clean. Good."
        ,"Huck, the Soldier: Combat has ended. Let's continue."
        ,"Huck, the Soldier: Good. Lead the way."
        ,"Huck, the Soldier: The spoils of war."
        ,"Huck, the Soldier: Worth fighting for?"
        ,"Huck, the Soldier: All yours. Don't need it."
        ,"Huck, the Soldier: Store it somewhere safe."
        ,"Huck, the Soldier: Take it. It's yours."
        ,"Huck, the Soldier: Careful."
        ,"Huck, the Soldier: We might get noticed."
        ,"Huck, the Soldier: Shh, we're making too much noise."
        ,"Huck, the Soldier: I'm certain they're onto us."
        ,"Huck, the Soldier: Follow our escape plan!"
        ,"Huck, the Soldier: To the exit, swiftly!"
        ,"Huck, the Soldier: Move, and don't stop moving!"
        ,"Huck, the Soldier: Damn, might have to cut this trip short!"
        ,"Huck, the Soldier: We're busted! Just try to escape!"
        ,"Huck, the Soldier: Might have to forget the target. Focus on survival!"
        ,"Huck, the Soldier: Target, dead ahead."
        ,"Huck, the Soldier: Eyes on the target."
        ,"Huck, the Soldier: Target's right there."
        ,"Huck, the Soldier: Spotted the target."
        ,"Huck, the Soldier: Go get the target. I've got you."
        ,"Huck, the Soldier: Target acquired. Let's move out."
        ,"Huck, the Soldier: Target obtained. Make tracks."
        ,"Huck, the Soldier: Got it. Time to escape."
        ,"Huck, the Soldier: Protect it with--, well not your life, but protect it."
        ,"Huck, the Soldier: Not a problem!"
        ,"Huck, the Soldier: Yessir!"
        ,"Huck, the Soldier: On it!"
        ,"Huck, the Soldier: Buy me some time!"
        ,"Huck, the Soldier: I'll do my best!"
        ,"Huck, the Soldier: Right! I've got this!"
        ,"Huck, the Soldier: Right!"
        ,"Huck, the Soldier: Sir!"
        ,"Huck, the Soldier: Got it!"
        ,"Huck, the Soldier: Gods, reckon I can handle it!"
        ,"Huck, the Soldier: Should've stretched for this!"
        ,"Huck, the Soldier: C'mon soldier! C'mon!"
        ,"Huck, the Soldier: Sir!"
        ,"Huck, the Soldier: Yes!"
        ,"Huck, the Soldier: Stand clear!"
        ,"Huck, the Soldier: Get back!"
        ,"Huck, the Soldier: Ordinance going down!"
        ,"Huck, the Soldier: Keep back! Keep back!"
        ,"Huck, the Soldier: Got a higher priority!"
        ,"Huck, the Soldier: Next on the list!"
        ,"Huck, the Soldier: Not now! Not now!"
        ,"Huck, the Soldier: No, I need time!"
        ,"Huck, the Soldier: This first! Then that!"
        ,"Huck, the Soldier: Get off me!"
        ,"Huck, the Soldier: Need help here!"
        ,"Huck, the Soldier: Where's my backup, dammit!"
        ,"Huck, the Soldier: Under attack!"
        ,"Huck, the Soldier: Incoming!"
        ,"Huck, the Soldier: Got company!"
        ,"Huck, the Soldier: Arms ready!"
        ,"Huck, the Soldier: Combat positions!"
        ,"Huck, the Soldier: Fighters inbound!"
        ,"Huck, the Soldier: Clear! Move!"
        ,"Huck, the Soldier: All clear!"
        ,"Huck, the Soldier: Go! Go! Go!"
        ,"Huck, the Soldier: Don't lose momentum!"
        ,"Huck, the Soldier: Good! Keep going!"
        ,"Huck, the Soldier: Don't put me at risk for this!"
        ,"Huck, the Soldier: Stash it and move!"
        ,"Huck, the Soldier: Secure it! We're moving!"
        ,"Huck, the Soldier: Got it? Good! Go!"
        ,"Huck, the Soldier: Greed gets people killed!"
        ,"Huck, the Soldier: Target spotted!"
        ,"Huck, the Soldier: There's the objective!"
        ,"Huck, the Soldier: Secure the objective!"
        ,"Huck, the Soldier: It's there! Close in!"
        ,"Huck, the Soldier: Right there! Exile, Go!"
        ,"Huck, the Soldier: Great! Mission ain't over yet!"
        ,"Huck, the Soldier: Time to retreat!"
        ,"Huck, the Soldier: Move to the exit!"
        ,"Huck, the Soldier: Got it? Then move!"]
    local islaLines
    islaLines := ["Isla, the Engineer: A simple solution!"
        ,"Isla, the Engineer: Just a matter of math!"
        ,"Isla, the Engineer: Hardly a hurdle!"
        ,"Isla, the Engineer: The axles and the gears go 'round and 'round..."
        ,"Isla, the Engineer: You put the axle in, you take the ball-bearing out..."
        ,"Isla, the Engineer: Sometimes there's an elegant solution... sometimes."
        ,"Isla, the Engineer: I've got just the contraption for this!"
        ,"Isla, the Engineer: Leave it to your engineer."
        ,"Isla, the Engineer: Alright, alright!"
        ,"Isla, the Engineer: Carry the seven..."
        ,"Isla, the Engineer: Such awful racket!"
        ,"Isla, the Engineer: Must go faster, must go faster."
        ,"Isla, the Engineer: Can't think with all that racket!"
        ,"Isla, the Engineer: You can't rush engineering!"
        ,"Isla, the Engineer: I'll do what I can!"
        ,"Isla, the Engineer: Time to take it apart!"
        ,"Isla, the Engineer: Let's throw a wrench in the works."
        ,"Isla, the Engineer: My turn!"
        ,"Isla, the Engineer: Construction, deconstruction... it's all the same, in the end."
        ,"Isla, the Engineer: A beautiful design. A shame I have to wreck it."
        ,"Isla, the Engineer: Traps are the arse end of engineering. No artisanship."
        ,"Isla, the Engineer: Thrilling!"
        ,"Isla, the Engineer: The fun part!"
        ,"Isla, the Engineer: Careful and quick!"
        ,"Isla, the Engineer: I'm just going to smack it with a wrench!"
        ,"Isla, the Engineer: Poor parts, bad craftsmanship!"
        ,"Isla, the Engineer: I can't even hear myself think!"
        ,"Isla, the Engineer: Just a moment."
        ,"Isla, the Engineer: A moment please."
        ,"Isla, the Engineer: I'm in the middle of something."
        ,"Isla, the Engineer: I'm engaged already."
        ,"Isla, the Engineer: One job at a time!"
        ,"Isla, the Engineer: I'm working!"
        ,"Isla, the Engineer: I'm on the job already!"
        ,"Isla, the Engineer: Don't deviate from the plan!"
        ,"Isla, the Engineer: Machines have a limit!"
        ,"Isla, the Engineer: I can't, I can't!"
        ,"Isla, the Engineer: They're touching me!"
        ,"Isla, the Engineer: Aren't you supposed to defend your engineer?!"
        ,"Isla, the Engineer: They're in my personal space!"
        ,"Isla, the Engineer: I can't think when I'm under attack!"
        ,"Isla, the Engineer: Get them away from me!"
        ,"Isla, the Engineer: They're going to deconstruct me!"
        ,"Isla, the Engineer: Personal space, personal space!"
        ,"Isla, the Engineer: This plan is crumbling!"
        ,"Isla, the Engineer: We've been sighted!"
        ,"Isla, the Engineer: Oh my, someone must do the fighting now."
        ,"Isla, the Engineer: I hope you don't expect me to fight."
        ,"Isla, the Engineer: A better plan would have avoided this."
        ,"Isla, the Engineer: Not good. Not good at all!"
        ,"Isla, the Engineer: Enemies approaching!"
        ,"Isla, the Engineer: Don't let them touch me!"
        ,"Isla, the Engineer: The jig's up!"
        ,"Isla, the Engineer: Consarn it, a fight's on!"
        ,"Isla, the Engineer: Zooterkins, here comes a beating!"
        ,"Isla, the Engineer: We... survived?"
        ,"Isla, the Engineer: Interesting tactics."
        ,"Isla, the Engineer: Their strategy was incorrect."
        ,"Isla, the Engineer: They made a tactical error."
        ,"Isla, the Engineer: They should have thought this through."
        ,"Isla, the Engineer: Violence complete!"
        ,"Isla, the Engineer: Continue with the plan!"
        ,"Isla, the Engineer: No time to waste!"
        ,"Isla, the Engineer: Like clockwork!"
        ,"Isla, the Engineer: Must get back on schedule!"
        ,"Isla, the Engineer: That'll fund a few inventions."
        ,"Isla, the Engineer: If they cannot prevent us from taking it, it is ours."
        ,"Isla, the Engineer: A good plan reaps its own rewards."
        ,"Isla, the Engineer: Don't deviate too much."
        ,"Isla, the Engineer: I believe they call that loot."
        ,"Isla, the Engineer: Treasure. Check. Keep moving."
        ,"Isla, the Engineer: The plan was to get treasure before the alarm!"
        ,"Isla, the Engineer: Now's not the time for looting!"
        ,"Isla, the Engineer: We get nothing if the plan fails!"
        ,"Isla, the Engineer: Why are you doing that now?!"
        ,"Isla, the Engineer: We're at the limits of our plan now."
        ,"Isla, the Engineer: This clock is on the verge of chiming..."
        ,"Isla, the Engineer: We can afford no more unanticipated variables."
        ,"Isla, the Engineer: We will be detected if we are not careful."
        ,"Isla, the Engineer: The clock chimes at the appointed hour!"
        ,"Isla, the Engineer: According to plan."
        ,"Isla, the Engineer: Right on cue."
        ,"Isla, the Engineer: I don't like surprises!"
        ,"Isla, the Engineer: This wasn't the plan!"
        ,"Isla, the Engineer: Our design appears to have been flawed!"
        ,"Isla, the Engineer: Flawless execution... so far."
        ,"Isla, the Engineer: Phase one complete. Acquire the treasure."
        ,"Isla, the Engineer: Remember, this is only the midpoint."
        ,"Isla, the Engineer: From the blueprints, I thought it'd be bigger."
        ,"Isla, the Engineer: I haven't even used half my contraptions yet!"
        ,"Isla, the Engineer: No time!"
        ,"Isla, the Engineer: Accelerate the plan!"
        ,"Isla, the Engineer: Timetable's up!"
        ,"Isla, the Engineer: Move quickly!"
        ,"Isla, the Engineer: Hurry!"
        ,"Isla, the Engineer: Objective achieved!"
        ,"Isla, the Engineer: Apex of the plan accomplished. Now, to survive!"
        ,"Isla, the Engineer: Phase two begins now!"
        ,"Isla, the Engineer: Oh, that's it? Hmm."
        ,"Isla, the Engineer: I recommend flight!"
        ,"Isla, the Engineer: Time to flee!"
        ,"Isla, the Engineer: Let's run!"
        ,"Isla, the Engineer: Got it? Let's go!"]
    if (checkLineHas(line, giannaLines))
    {
        hasGianna := selectRecord("HeistGianna", true)
    }
    if (checkLineHas(line, huckLines))
    {
        hasHuck := selectRecord("HeistHuck", true)
    }
    if (checkLineHas(line, tibbsLines))
    {
        hasTibbs := selectRecord("HeistTibbs", true)
    }
    if (checkLineHas(line, vinderiLines))
    {
        hasVinderi := selectRecord("HeistVinderi", true)
    }
    if (checkLineHas(line, tullinaLines))
    {
        hasTullina := selectRecord("HeistTullina", true)
    }
    if (checkLineHas(line, nenetLines))
    {
        hasNenet := selectRecord("HeistNenet", true)
    }
    if (checkLineHas(line, islaLines))
    {
        hasIsla := selectRecord("HeistIsla", true)
    }
    if (checkLineHas(line, karstLines))
    {
        hasKarst := selectRecord("HeistKarst", true)
    }
    if (checkLineHas(line, nilesLines))
    {
        hasNiles := selectRecord("HeistNiles", true)
    }
    local numRogues
    numRogues := hasGianna + hasHuck + hasTibbs + hasVinderi + hasTullina + hasIsla + hasKarst + hasNiles
    if (numRogues > 1)
    {
        isBlueprint := selectRecord("HeistBlueprint", true)
    }
}

convertDelta(ct)
{
    mins := Floor(ct/1000/60)
    ct -= mins * 1000 * 60
    mins := Format("{:02}",mins)
    secs := Floor(ct/1000)
    ct -= secs * 1000
    secs := Format("{:02}",secs)
    subsec := Format("{:01}",Floor(ct/100))
    return mins ":" secs "." subsec
}

dumpData()
{
    global
    local dtg
    local filename
    local ff

    FormatTime, dtg,, yyyy_MM_dd_HH_mm_ss
    filename := "heists/heist_" dtg ".txt"
    ff := FileOpen(filename, "w")
    if (HeistTimerGrab > HeistTimerStart)
    {
        ff.WriteLine("GrabTime:" HeistTimerGrab - HeistTimerStart)
    }
    ff.WriteLine("EndTime:" HeistTimerStop - HeistTimerStart)
    if (isBlueprint)
    {
        ff.WriteLine("Type:Blueprint")
    }
    else
    {
        ff.WriteLine("Type:Contract")
    }
    if (hasGianna)
    {
        ff.WriteLine("Gianna:True")
    }
    if (hasHuck)
    {
        ff.WriteLine("Huck:True")
    }
    if (hasTibbs)
    {
        ff.WriteLine("Tibbs:True")
    }
    if (hasVinderi)
    {
        ff.WriteLine("Vinderi:True")
    }
    if (hasTullina)
    {
        ff.WriteLine("Tullina:True")
    }
    if (hasIsla)
    {
        ff.WriteLine("Isla:True")
    }
    if (hasKarst)
    {
        ff.WriteLine("Karst:True")
    }
    if (hasNiles)
    {
        ff.WriteLine("Niles:True")
    }
    if (hasNenet)
    {
        ff.WriteLine("Nenet:True")
    }
    loop, 22
    {
        ff.WriteLine(heistLootType[A_Index] ":" heistLootCount[A_Index])
    }
    local endinv
    endinv := getInventory()
    local deltainv
    deltainv := compareInventory(OldInventory,endinv)
    OldInventory := endinv
    ff.Write(deltainv)
    ff.Close()
}

goto HeistTrackingDone

HeistTicker:
    global ClientTxt
    if (ClientTxt.AtEOF)
    {
        if (HeistTimerState > 0)
        {
            global HeistTimerStart
            global HeistTimerGrab
            tt := A_TickCount
            ct := tt - HeistTimerStart
            ct := convertDelta(ct)
            GuiControl, RecordHeist:, HeistMainTime, %ct%
            if (HeistTimerState = 1)
            {
                GuiControl, RecordHeist:, HeistGrabTime, %ct%
            }
            if (HeistTimerState = 2)
            {
                ct := tt - HeistTimerGrab   
                ct := convertDelta(ct)
                GuiControl, RecordHeist:, HeistCompleteTime, %ct%
            }
        }
    }
    else
    {
        line := ClientTxt.ReadLine()
        if (HeistTimerState = 0)
        {
            if (checkStart(line))
            {
                startTimer()
            }
        }
        else
        {
            if (checkDied(line))
            {
                resetHeistRecord()
            }
            else if (checkCompleted(line))
            {
                global HeistTimerStop
                HeistTimerStop := A_TickCount
                dumpData()
                resetHeistRecord()
            } else {
                checkRogues(line)
                if (HeistTimerState = 1)
                {
                    if (checkGrab(line))
                    {
                        HeistTimerGrab := A_TickCount
                        HeistTimerState = 2
                    }

                }
            }
        }

    }
Return

HeistLoot_1:
    indexLoot(1)
Return
HeistLoot_2:
    indexLoot(2)
Return
HeistLoot_3:
    indexLoot(3)
Return
HeistLoot_4:
    indexLoot(4)
Return
HeistLoot_5:
    indexLoot(5)
Return
HeistLoot_6:
    indexLoot(6)
Return
HeistLoot_7:
    indexLoot(7)
Return
HeistLoot_8:
    indexLoot(8)
Return
HeistLoot_9:
    indexLoot(9)
Return
HeistLoot_10:
    indexLoot(10)
Return
HeistLoot_11:
    indexLoot(11)
Return
HeistLoot_12:
    indexLoot(12)
Return
HeistLoot_13:
    indexLoot(13)
Return
HeistLoot_14:
    indexLoot(14)
Return
HeistLoot_15:
    indexLoot(15)
Return
HeistLoot_16:
    indexLoot(16)
Return
HeistLoot_17:
    indexLoot(17)
Return
HeistLoot_18:
    indexLoot(18)
Return
HeistLoot_19:
    indexLoot(19)
Return
HeistLoot_20:
    indexLoot(20)
Return
HeistLoot_21:
    indexLoot(21)
Return
HeistLoot_22:
    indexLoot(22)
Return

SelectBlueprint:
    global isBlueprint
    isBlueprint := toggleRecord("HeistBlueprint", isBlueprint)
Return
SelectKarst:
    global hasKarst
    hasKarst := toggleRecord("HeistKarst", hasKarst)
Return
SelectNiles:
    global hasNiles
    hasNiles := toggleRecord("HeistNiles", hasNiles)
Return
SelectHuck:
    global hasHuck
    hasHuck := toggleRecord("HeistHuck", hasHuck)
Return
SelectTibbs:
    global hasTibbs
    hasTibbs := toggleRecord("HeistTibbs", hasTibbs)
Return
SelectNenet:
    global hasNenet
    hasNenet := toggleRecord("HeistNenet", hasNenet)
Return
SelectVinderi:
    global hasVinderi
    hasVinderi := toggleRecord("HeistVinderi", hasVinderi)
Return
SelectTullina:
    global hasTullina
    hasTullina := toggleRecord("HeistTullina", hasTullina)
Return
SelectIlsa:
    global hasIsla
    hasIsla := toggleRecord("HeistIsla", hasIsla)
Return
SelectGianna:
    global hasGianna
    hasGianna := toggleRecord("HeistGianna", hasGianna)
Return

ResetHeistTime:
    resetHeistRecord()
    if (!initTimer())
    {
        MsgBox, Could not open ClientTxt
    }
Return


OpenRecordWindow:
    Gui, RecordHeistDrops:Show
Return

RecordHeistDropsEscape:
RecordHeistDropsClose:
    Gui, RecordHeistDrops:Hide
Return

compareInventory(inv1, inv2)
{
    VarSetCapacity(delta, 2*2000)
    DllCall("snipper\CompareInventory","Str",inv1,"Str",inv2,"Str",delta)
    CheckError("Snipper\CleanInventory", ErrorLevel)

    return delta
}

getInventory()
{
    poesessid := getSetting("User", "POESESSID")
    account := getSetting("User", "Account")
    char := getSetting("User", "Character")
    league := getSetting("General", "League")
    invgrab := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    invgrab.Open("GET", "https://www.pathofexile.com/character-window/get-items?league=" league "&AccountName=" account "&character=" char, true)
    cookieString := "POESESSID=" poesessid
    invgrab.SetRequestHeader("Cookie", cookieString)
    invgrab.Send()
    invgrab.WaitForResponse()
    thisText := invgrab.responseText
    return thisText
}

HeistTrackingDone: