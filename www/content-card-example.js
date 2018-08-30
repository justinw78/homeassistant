class ContentCardExample extends HTMLElement {
  set hass(hass) {
    if (!this.content) {
      const card = document.createElement('ha-card');
      card.header = 'Eerstvolgende Ophaaldag';
      this.content = document.createElement('div');
      this.content.style.padding = '0 16px 16px';
      card.appendChild(this.content);
      this.appendChild(card);
    }

    const entityId = this.config.entity;
    const state = hass.states[entityId];
    const stateStr = state ? state.state : 'unavailable';

    this.content.innerHTML = `

	<table style="width: 300px;">
<tbody>
<tr>
<td style="width: 80px;"><img src="${hass.states['sensor.afval'].attributes.entity_picture}" alt="" width="80px" height="80px" /></td>
<td style="width: 220px;">
<h3 style="text-align: center;"><span style="color: #00ff00;"><strong>${hass.states['sensor.afvalsoort'].state}</strong></span></h3>
<h2 style="text-align: center;"><strong>${hass.states['sensor.afvaldate'].state}</strong></h2>
</td>
</tr>
</tbody>
</table>
	
    `;
  }

  setConfig(config) {
    if (!config.entity) {
      throw new Error('You need to define an entity');
    }
    this.config = config;
  }

  // The height of your card. Home Assistant uses this to automatically
  // distribute all cards over the available columns.
  getCardSize() {
    return 1;
  }
}

customElements.define('content-card-example', ContentCardExample);