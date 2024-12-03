import { Hono } from 'hono'
import { cors } from 'hono/cors'

const app = new Hono()

// Enable CORS
app.use('/*', cors({
  origin: '*',
  allowMethods: ['POST', 'GET', 'OPTIONS'],
  allowHeaders: ['Content-Type'],
  exposeHeaders: ['Content-Length', 'Content-Type'],
  maxAge: 600,
  credentials: true,
}))

app.get('/', (c) => {
  return c.text('ReadItFast API')
})

// Mock text-to-speech endpoint
app.post('/api/tts', async (c) => {
  try {
    const { text } = await c.req.json()
    
    if (!text) {
      return c.json({ error: 'Text is required' }, 400)
    }

    // For now, return a mock audio file URL
    // In real implementation, this would be the URL of the generated audio file
    return c.json({
      audioUrl: 'https://www2.cs.uic.edu/~i101/SoundFiles/gettysburg.wav',
      duration: 17.0, // mock duration in seconds
      text: text,
      timestamp: new Date().toISOString()
    })

  } catch (error) {
    console.error('Error in TTS endpoint:', error)
    return c.json({ error: 'Failed to process text' }, 500)
  }
})

export default app
