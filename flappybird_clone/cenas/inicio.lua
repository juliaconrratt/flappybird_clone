local composer = require('composer')

local cena = composer.newScene()

function cena:create( event )
  local grupoInicio = self.view

  --- Variáveis de posicionamento

  local x = display.contentWidth
  local y = display.contentHeight
  local t = x + y

  --- Áudio

  local musica = audio.loadStream( 'Resource/audio/music.mp3' )
  audio.play( musica, {channel = 32, loops = 0} )
  audio.setVolume( 0.3, {channel = 32} )

  local audioTransicao = audio.loadSound( 'Resource/audio/swoosh.mp3' )

  --- Declaração elementos aleatórios

  local imagens = {
    fundo = {
      'Resource/images/background-day.png',
      'Resource/images/background-night.png'
    }
  }

  local randomFundo = imagens.fundo[ math.random( 1, 2 ) ]

  --- Elementos

  local fundo = display.newImageRect( grupoInicio, randomFundo, x, y )
  fundo.x = x*0.5
  fundo.y = y*0.5

  local chao = display.newImageRect( grupoInicio, 'Resource/images/base.png', x, y*0.1 )
  chao.x = x*0.5
  chao.y = y*0.95

  local inicio = display.newImageRect( grupoInicio, 'Resource/images/start.png', x*0.9, y*0.6 )
  inicio.x = x*0.5
  inicio.y = y*0.5

  function iniciarJogo( event )
    if event.phase == 'began' then
      composer.gotoScene( 'cenas.jogo', {
        time = 500, effect = 'slideLeft'
      })
      audio.play( audioTransicao )
    end
  end
  inicio:addEventListener('touch', iniciarJogo)

  
end
cena:addEventListener('create', cena)
return cena 