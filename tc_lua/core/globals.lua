local Globals = { }

Globals.V0 = Vector(0, 0)

Globals.Game = Game()
Globals.SFX = SFXManager()
Globals.rng = RNG()
Globals.rng:SetSeed(Random() + 1, 75)

Globals.Room = nil
Globals.Level = nil

return Globals;