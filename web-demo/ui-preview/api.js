// 浏览器只访问自己的后端；模型网关与密钥不进入前端。
const kitchenApi = {
  base: location.port === '8765' ? 'http://127.0.0.1:8000' : location.origin,
  async explore(input, signal) {
    let response;
    try {
      response = await fetch(`${this.base}/api/explorations`, {
        method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(input), signal
      });
    } catch (error) {
      if (error.name === 'AbortError') throw error;
      throw new Error('连接不上服务，请确认本机后端已启动。');
    }
    const data = await response.json().catch(() => null);
    if (!response.ok) throw new Error(data?.detail || '暂时没有取得结果，请重试。');
    if (!data || !['ready','needs_input'].includes(data.status)) throw new Error('分析结果不完整，请重试。');
    return data;
  },
  async photoData(file) {
    if (file.size > 20 * 1024 * 1024) throw new Error('照片太大，请选择小于 20 MB 的图片。');
    const image = new Image(), url = URL.createObjectURL(file);
    try {
      image.src = url;
      await image.decode();
      const scale = Math.min(1, 1600 / Math.max(image.width,image.height));
      const canvas = document.createElement('canvas');
      canvas.width = Math.max(1,Math.round(image.width*scale));
      canvas.height = Math.max(1,Math.round(image.height*scale));
      canvas.getContext('2d').drawImage(image,0,0,canvas.width,canvas.height);
      return canvas.toDataURL('image/jpeg',0.85);
    } catch {
      throw new Error('无法读取这张照片，请使用 JPG、PNG 或 WebP 图片。');
    } finally { URL.revokeObjectURL(url); }
  }
};
