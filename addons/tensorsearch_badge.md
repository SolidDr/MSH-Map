<svg width="162" height="46" viewBox="0 0 162 46" xmlns="http://www.w3.org/2000/svg">
  <!-- Dunkler Hintergrund -->
  <rect width="162" height="46" fill="#0a0a0d" rx="5"/>
  
  <defs>
    <linearGradient id="hexGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#3a5a4a"/>
      <stop offset="100%" stop-color="#a08528"/>
    </linearGradient>
  </defs>
  
  <!-- Hexagon Icon -->
  <g transform="translate(19, 22)">
    <polygon points="0,-9 7.8,-4.5 7.8,4.5 0,9 -7.8,4.5 -7.8,-4.5" fill="none" stroke="url(#hexGrad)" stroke-width="1.2" opacity="0.6">
      <animate attributeName="stroke-dasharray" values="0,100;47,0" dur="5s" repeatCount="indefinite"/>
    </polygon>
    <circle r="3.5" fill="#c9a227">
      <animate attributeName="r" values="3;4;3" dur="3s" repeatCount="indefinite"/>
    </circle>
    <circle r="3.5" fill="none" stroke="#c9a227" stroke-width="0.7">
      <animate attributeName="r" values="3.5;8" dur="3s" repeatCount="indefinite"/>
      <animate attributeName="opacity" values="0.35;0" dur="3s" repeatCount="indefinite"/>
    </circle>
  </g>
  
  <!-- Powered by -->
  <text x="38" y="16" fill="#666" font-size="7" font-family="system-ui, sans-serif" letter-spacing="0.3">Powered by</text>
  
  <!-- KOLAN Tensor -->
  <text x="38" y="30" font-family="system-ui, sans-serif">
    <tspan fill="#c9a227" font-size="13" font-weight="600">KOLAN</tspan>
    <tspan fill="#bbb" font-size="13" font-weight="400" dx="3">Tensor</tspan>
  </text>
  
  <!-- search - nach links (x=119) und oben (y=37) -->
  <text x="119" y="37" fill="#555" font-size="7" font-family="system-ui, sans-serif">search</text>
</svg>