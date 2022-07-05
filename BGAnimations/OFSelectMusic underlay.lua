local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	Name = 'Underlay',
	OnCommand = function(self)
		-- discord support UwU -y0sefu
		local player = GAMESTATE:GetMasterPlayerNumber()
		if player then
			GAMESTATE:UpdateDiscordProfile(GAMESTATE:GetPlayerDisplayName(player))
		end
		if GAMESTATE:IsCourseMode() then
			GAMESTATE:UpdateDiscordScreenInfo("Selecting Course","",1)
		else
			local StageIndex = GAMESTATE:GetCurrentStageIndex()
			GAMESTATE:UpdateDiscordScreenInfo("Selecting a Song (Stage ".. StageIndex + 1 .. ")	","",1)
		end
	end,
	Def.Sprite {
		Name = 'Background',
		InitCommand = function(self)
			self
				:Center()
				:scaletoclipped(SCREEN_WIDTH, SCREEN_HEIGHT)
		end,
		CurrentSongChangedMessageCommand = function(self)
			self
				:stoptweening()
				:easeinoutsine(0.2)
				:diffusealpha(0)
				:sleep(0.1)
				:queuecommand('LoadBackground')
		end,
		LoadBackgroundCommand = function(self)
			if not GAMESTATE:IsCourseMode() and SU_Wheel.CurSong:GetPreviewVidPath() then
				self:Load(SU_Wheel.CurSong:GetPreviewVidPath())
			else
				self:LoadFromSongBackground(SU_Wheel.CurSong)
			end
			self
				:easeinoutsine(0.5)
				:diffusealpha(0.25)
		end,
	},
	Def.ActorFrame {
		Name = 'BannerFrame',
		InitCommand = function(self)
			self:xy(290, 250)
		end,
		Def.Banner {
			Name = 'Banner',
			InitCommand = function(self)
				--self:scaletoclipped(512, 160)
			end,
			CurrentSongChangedMessageCommand = function(self)
				self
					:stoptweening()
					:linear(0.1)
					:diffusealpha(0)
					:sleep(0.25)
					:queuecommand('LoadBanner')
			end,
			LoadBannerCommand = function(self)
				local song = SU_Wheel.CurSong
				if song:HasBanner() then
					self:LoadFromCachedBanner(song:GetBannerPath())
				else
					self:LoadFromSongGroup(song:GetGroupName())
				end
				local w, h = self:GetWidth(), self:GetHeight()
				self:zoomto(160 * w/h, 160)
				self:easeinoutsine(0.2):diffusealpha(1)
			end,
		},
	},
	Def.ActorFrame {
		Name = 'InfoFrame',
		InitCommand = function(self)
			self:xy(290, 440)
		end,
		Def.BitmapText {
			Font = 'Common Large',
			Name = 'Title',
			InitCommand = function(self)
				self
					:valign(1)
					:addy(-24)
					:maxwidth(488)
			end,
			CurrentSongChangedMessageCommand = function(self)
				self
					:stoptweening()
					:linear(0.1)
					:diffusealpha(0)
					:sleep(0.25)
					:queuecommand('LoadTitle')
			end,
			LoadTitleCommand = function(self)
				local song = SU_Wheel.CurSong
				local title = song:GetDisplayFullTitle()
				if not GAMESTATE:IsCourseMode() then
					if song:GetDisplaySubTitle() and song:GetDisplaySubTitle() ~= '' then
						title = song:GetDisplayMainTitle()..'\n'..song:GetDisplaySubTitle()
					end
				end
				self
					:settext(title)
					:easeinoutsine(0.2)
					:diffusealpha(1)
			end,
		},
		Def.BitmapText {
			Font = 'Common Large',
			Name = 'Separator',
			Text = '--',
			InitCommand = function(self)
				self
					:maxwidth(488)
					:diffusealpha(0)
			end,
			CurrentSongChangedMessageCommand = function(self)
				self
					:stoptweening()
					:linear(0.1)
					:diffusealpha(0)
					:sleep(0.25)
					:easeinoutsine(0.2)
					:diffusealpha(1)
			end,
		},
		Def.BitmapText {
			Font = 'Common Large',
			Name = 'Artist',
			InitCommand = function(self)
				self
					:valign(0)
					:addy(24)
					:maxwidth(488)
			end,
			CurrentSongChangedMessageCommand = function(self)
				self
					:stoptweening()
					:linear(0.1)
					:diffusealpha(0)
					:sleep(0.25)
					:queuecommand('LoadArtist')
			end,
			LoadArtistCommand = function(self)
				local song = SU_Wheel.CurSong
				local artist = (GAMESTATE:IsCourseMode() and song:GetScripter()) or song:GetDisplayArtist()
				self
					:settext(artist)
					:easeinoutsine(0.2)
					:diffusealpha(1)
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			Name = 'Misc',
			InitCommand = function(self)
				self
					:valign(0)
					:addy(78)
					:maxwidth(488)
			end,
			CurrentSongChangedMessageCommand = function(self)
				self
					:stoptweening()
					:linear(0.1)
					:diffusealpha(0)
					:sleep(0.25)
					:queuecommand('LoadMisc')
			end,
			LoadMiscCommand = function(self)
				if GAMESTATE:IsCourseMode() then return end
				local song = SU_Wheel.CurSong
				local data = {
					(song:IsDisplayBpmRandom() and '???') or tostring(math.floor(song:GetDisplayBpms()[2])),
					SecondsToMSS(song:GetStepsSeconds())
				}
				local str = (
					'BPM: '..
					-- If we have significant BPM changes to display and we're not just doubling BPM, put both display BPMs.
					(((not song:IsDisplayBpmSpecified() and song:HasSignificantBPMChanges() and (song:GetDisplayBpms()[2] / song:GetDisplayBpms()[1] ~= 2)) and tostring(math.floor(song:GetDisplayBpms()[1])..'-')) or '')..
					data[1]..
					'  |  Length: '..
					data[2]
				)
				self
					:settext(str)
					:easeinoutsine(0.2)
					:diffusealpha(1)
			end,
		}
	},
}
