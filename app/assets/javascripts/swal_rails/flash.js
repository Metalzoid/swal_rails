const readFlash = () => {
  const el = document.querySelector('meta[name="swal-flash"]')
  if (!el) return []
  try { return JSON.parse(el.getAttribute("content")) || [] } catch { return [] }
}

export const installFlash = (Swal, config) => {
  const flashes = readFlash()
  if (!flashes.length) return

  const map = config.flashMap || {}
  const queue = flashes.map((flash) => {
    const spec = map[flash.key] || map[flash.key.toLowerCase()] || { icon: "info", toast: true, position: "top-end", timer: 3000 }
    // Per-request options win over the per-key defaults from flash_map.
    return { ...spec, ...(flash.options || {}) }
  })

  const fireNext = () => {
    const opts = queue.shift()
    if (!opts) return
    Swal.fire(opts).then(fireNext)
  }
  fireNext()
}
