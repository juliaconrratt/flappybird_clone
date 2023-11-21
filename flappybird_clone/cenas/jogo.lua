local composer = require('composer')

local cena = composer.newScene()

function cena:create( event )
  local cenaJogo = self.view

  --- Variáveis de posicionamento

  local x = display.contentWidth
  local y = display.contentHeight
  local t = x + y

  --- Áudios

  local audioMorte = audio.loadSound( 'Resource/audio/die.mp3' )
  local audioVoar = audio.loadSound( 'Resource/audio/wing.mp3' )
  local audioPonto = audio.loadSound( 'Resource/audio/point.mp3' )

  --- Grupos

  local grupoFundo = display.newGroup()
  local grupoJogo = display.newGroup()
  local grupoGUI = display.newGroup()

  cenaJogo:insert(grupoFundo)
  cenaJogo:insert(grupoJogo)
  cenaJogo:insert(grupoGUI)

  --- Declaração elementos aleatórios

  local imagens = {
    fundo = {
      'Resource/images/background-day.png',
      'Resource/images/background-night.png'
    },
    canos = {
      'Resource/images/pipe-green.png',
      'Resource/images/pipe-red.png'
    },
    passaro = {
      'Resource/images/bluebird.png',
      'Resource/images/redbird.png',
      'Resource/images/yellowbird.png'
    }
  }

  local randomPassaro = imagens.passaro[ math.random( 1, 3 ) ]
  local randomFundo = imagens.fundo[ math.random( 1, 2 ) ]
  local randomCano = imagens.canos[ math.random( 1, 2 ) ]

  --- Physics

  local physics = require('physics')
  physics.start()
  physics.setGravity( 0, 80 )
  physics.setDrawMode( 'normal' )

  -- Declaração das variáveis

  local vivo = true

  -- Declaração pontuação

  local pontos = 0
  local pontosTexto = display.newText( grupoGUI, pontos, x*0.5, y*0.15, 'Resource/fonts/font.ttf', t*0.08 )  

  --- Elementos

  local fundo = display.newImageRect( grupoFundo, randomFundo, x, y )
  fundo.x = x*0.5
  fundo.y = y*0.5
  fundo.id = 'fundoID'

  local passaro = display.newImageRect( grupoJogo, randomPassaro, t*0.05, t*0.05 )
  passaro.x = x*0.2
  passaro.y = y*0.3
  passaro.id = 'passaroID'
  physics.addBody( passaro, 'dynamic' )

  local chao = display.newImageRect( grupoJogo, 'Resource/images/base.png', x, y*0.1 )
  chao.x = x*0.5
  chao.y = y*0.95
  chao.id = 'chaoID'
  physics.addBody( chao, 'static' )
  
  --- Canos

 function criaCano( )
   if vivo == true then
     local canoInferior = display.newImageRect( grupoJogo, randomCano, x*0.2, y*0.8 )
     canoInferior.x = x*1.2
     canoInferior.y = math.random( y*0.9, y*1.2)
     canoInferior.id = 'canoInferiorID'
     physics.addBody( canoInferior, 'static' )

     transition.to( canoInferior, {
      time = 3500,
      x = x*-0.2,
      onComplete = function ()
       display.remove( canoInferior )
      end
     } )

     local canoSuperior = display.newImageRect( grupoJogo, randomCano, x*0.2, y*0.8 )
     canoSuperior.x = canoInferior.x
     canoSuperior.y = canoInferior.y -y*1.05
     canoSuperior.rotation = 180
     canoSuperior.id = 'canoSuperiorID'
     physics.addBody( canoSuperior, 'static' )
  
     transition.to( canoSuperior, {
      time = 3500,
      x = x*-0.2,
      onComplete = function ()
       display.remove( canoSuperior )
      end
     } )

    
    local sensor = display.newRect( grupoJogo, canoInferior.x, canoInferior.y -y*0.525, t*0.065, t*0.15 )
    sensor.id = 'sensorID'
    physics.addBody( sensor, 'static' )
    sensor.isSensor = true
    sensor.alpha = 0

    transition.to( sensor, {
      time = 3500,
      x = x*-0.2,
      onComplete = function ()
       display.remove( sensor )
      end
     } )

   end
   
  end

 timer.performWithDelay( 2000, criaCano, 0 )

 --- Funções

 function voar( event )
  if event.phase == 'began' and vivo == true then
    passaro:setLinearVelocity( 0, -800 )
  end
 end

 Runtime:addEventListener('touch', voar)
 
 function derrota()
   vivo = false
   local perdeu = display.newImageRect( grupoJogo, 'Resource/images/gameover.png', x*0.8, y*0.08 )
   perdeu.x = x*0.5
   perdeu.y = y*0.5

   audio.play( audioMorte)

   timer.performWithDelay( 1500, function()
    display.remove( passaro )
    display.remove( chao )
    display.remove( canoInferior )
    display.remove( canoSuperior )
    composer.removeScene( 'cenas.jogo' )
    composer.gotoScene( 'cenas.inicio' )
   end, 1 )
 end

 function verificarColisao( event )
  if event.phase == 'began' then
    if event.object1.id == 'passaroID' and event.object2.id == 'chaoID' then
      derrota()
    end

    if event.object1.id == 'passaroID' and event.object2.id == 'canoInferiorID' then
      derrota()
    end

    if event.object1.id == 'passaroID' and event.object2.id == 'canoSuperiorID' then
      derrota()
    end

    if event.object1.id == 'passaroID' and event.object2.id == 'sensorID' or event.object2.id == 'passaroID' and event.object1.id == 'sensorID' then
      pontos = pontos + 1
      pontosTexto.text = pontos
      audio.play( audioPonto )
    end

  end
 end
 Runtime:addEventListener('collision', verificarColisao)

end
 

cena:addEventListener('create', cena)
return cena 