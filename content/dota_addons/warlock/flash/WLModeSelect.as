package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class WLModeSelect extends MovieClip
	{
		// element details filled out by game engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
	
		public function WLModeSelect()
        {

        }
		
		// called by the game engine when this .swf has finished loading
		public function onLoaded():void
		{
			gameAPI.SubscribeToGameEvent("w_start_mode_selection", startModeSelection);
			gameAPI.SubscribeToGameEvent("w_modes_selected", modesSelected);
			
			btnStartGame.addEventListener(MouseEvent.CLICK, startGameButtonClicked);
			
			//Hide unused
			lblMaxScore.visible = false;
			slMaxScore.visible = false;
			
			//Mode event listeners
			
			//Modes
			rbModeRounds.addEventListener(Event.CHANGE, modeChanged);
			
			//Team Modes
			rbTeamModeDefault.addEventListener(Event.CHANGE, teamModeChanged);
			rbTeamModeFFA.addEventListener(Event.CHANGE, teamModeChanged);
			rbTeamModeShuffle.addEventListener(Event.CHANGE, teamModeChanged);
			
			//Win Conditions
			rbWinConditionRound.addEventListener(Event.CHANGE, winConditionChanged);
			rbWinConditionScore.addEventListener(Event.CHANGE, winConditionChanged);
			slMaxScore.addEventListener(Event.CHANGE, maxScoreChanged);
			slRoundCount.addEventListener(Event.CHANGE, roundCountChanged);
			
			//Misc options
			cbUseTeamScore.addEventListener(Event.CHANGE, useTeamScoreChanged);
			cbNoDraws.addEventListener(Event.CHANGE, noDrawsChanged);
			
			
            trace("WLModeSelect loaded!");
		}
		
		// called by the game engine after onLoaded and whenever the screen size is changed
		public function onScreenSizeChanged():void
		{
			// By default, your 1024x768 swf is scaled to fit the vertical resolution of the game
			//   and centered in the middle of the screen.
			// You can override the scaling and positioning here if you need to.
			// stage.stageWidth and stage.stageHeight will contain the full screen size.
		}
		
		private function sendModeChanged(a:int, b:int):void
		{
			gameAPI.SendServerCommand("wl_set_mode " + a + " " + b);
		}
		
		private function maxScoreChanged(event:Event):void
		{
			lblWinConditionNumber.text = String(event.target.value);
			sendModeChanged(4, event.target.value);
		}
		
		private function roundCountChanged(event:Event):void
		{
			lblWinConditionNumber.text = String(event.target.value);
			sendModeChanged(5, event.target.value);
		}
		
		private function noDrawsChanged(event:Event):void
		{
			sendModeChanged(6, event.target.selected);
		}
		
		private function useTeamScoreChanged(event:Event):void
		{
			sendModeChanged(7, event.target.selected);
		}
		
		private function winConditionChanged(event:Event):void
		{
			if(event.target.selected)
			{
				sendModeChanged(3, event.target.value);
				
				var isMaxScore:Boolean = event.target == rbWinConditionScore;
		
				lblMaxScore.visible = isMaxScore;
				slMaxScore.visible = isMaxScore;
				lblRoundCount.visible = !isMaxScore;
				slRoundCount.visible = !isMaxScore;
				
				if(isMaxScore)
				{
					lblWinConditionNumber.text = String(slMaxScore.value);
				}
				else
				{
					lblWinConditionNumber.text = String(slRoundCount.value);
				}
			}
		}
		
		private function modeChanged(event:Event):void
		{
			if(event.target.selected)
			{
				sendModeChanged(2, event.target.value);
			}
		}
		
		private function teamModeChanged(event:Event):void
		{
			if(event.target.selected)
			{
				sendModeChanged(1, event.target.value);
			}
		}
		
		private function startGameButtonClicked(event:MouseEvent):void
		{
			selectMode();
		}
		
		private function selectMode():void
		{
			gameAPI.SendServerCommand("wl_select_mode");
		}
		
		private function startModeSelection(eventData:Object):void
		{
			if(eventData.id != globals.Players.GetLocalPlayer())
			{
				return;
			}

			visible = true;
		}
		
		private function modesSelected(eventData:Object):void
		{
			if(eventData.id != globals.Players.GetLocalPlayer())
			{
				return;
			}

			visible = false;
		}
	}
}
