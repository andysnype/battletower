sinon = require 'sinon'
{Battle, Pokemon} = require('../').server
{Factory} = require('./factory')

describe 'Battle', ->
  beforeEach ->
    @player1 = {id: 'abcde'}
    @player2 = {id: 'fghij'}
    team1   = [Factory('Hitmonchan'), Factory('Heracross')]
    team2   = [Factory('Hitmonchan'), Factory('Heracross')]
    players = [{player: @player1, team: team1},
               {player: @player2, team: team2}]
    @battle = new Battle('id', players: players)
    @team1  = @battle.getTeam(@player1.id)
    @team2  = @battle.getTeam(@player2.id)

  it 'starts at turn 1', ->
    @battle.turn.should.equal 1

  describe '#hasWeather(weatherName)', ->
    it 'returns true if the current battle weather is weatherName', ->
      @battle.weather = "Sunny"
      @battle.hasWeather("Sunny").should.be.true

    it 'returns false on non-None in presence of a weather-cancel ability', ->
      @battle.weather = "Sunny"
      sinon.stub(@battle, 'hasWeatherCancelAbilityOnField', -> true)
      @battle.hasWeather("Sunny").should.be.false

    it 'returns true on None in presence of a weather-cancel ability', ->
      @battle.weather = "Sunny"
      sinon.stub(@battle, 'hasWeatherCancelAbilityOnField', -> true)
      @battle.hasWeather("None").should.be.true

  describe '#makeMove', ->
    it "records a player's move", ->
      @battle.makeMove(@player1, 'Tackle')
      @battle.playerActions.should.have.property @player1.id
      @battle.playerActions[@player1.id].name.should.equal 'tackle'

    # TODO: Invalid moves should fail in some way.
    it "doesn't record invalid moves", ->
      @battle.makeMove(@player1, 'Blooberry Gun')
      @battle.playerActions.should.not.have.property @player1.id

    it "automatically ends the turn if all players move", ->
      mock = sinon.mock(@battle)
      mock.expects('continueTurn').once()
      @battle.makeMove(@player1, 'Tackle')
      @battle.makeMove(@player2, 'Tackle')
      mock.verify()

  describe '#switch', ->
    it "swaps pokemon positions of a player's team", ->
      [poke1, poke2] = @team1.pokemon
      @battle.switch(@player1, 1)
      @battle.continueTurn()
      @team1.pokemon.slice(0, 2).should.eql [poke2, poke1]

    it "automatically ends the turn if all players switch", ->
      mock = sinon.mock(@battle)
      mock.expects('continueTurn').once()
      @battle.switch(@player1, 1)
      @battle.switch(@player2, 1)
      mock.verify()
