const STYLE_LABELS = {
  rule_of_thirds: "九宫格",
  golden_ratio: "黄金分割",
  golden_spiral: "黄金螺旋",
  diagonal: "对角线"
};

function requestBridge(action, payload) {
  return new Promise((resolve) => {
    if (!window.sketchup || !window.sketchup[action]) {
      resolve(null);
      return;
    }

    window.sketchup[action](payload ? JSON.stringify(payload) : "", (response) => {
      resolve(response ? JSON.parse(response) : null);
    });
  });
}

function setSelectOptions(select, values, labelMap = {}) {
  select.innerHTML = "";
  values.forEach((value) => {
    const option = document.createElement("option");
    option.value = value;
    option.textContent = labelMap[value] || value;
    select.appendChild(option);
  });
}

function applyPayload(payload) {
  setSelectOptions(document.getElementById("composition_ratio_mode"), payload.ratio_options);
  setSelectOptions(document.getElementById("composition_style"), payload.style_options, STYLE_LABELS);

  Object.entries(payload).forEach(([key, value]) => {
    const element = document.getElementById(key);
    if (!element) {
      return;
    }

    if (element.type === "checkbox") {
      element.checked = Boolean(value);
    } else {
      element.value = value;
    }
  });
}

function collectPayload() {
  return {
    composition_ratio_mode: document.getElementById("composition_ratio_mode").value,
    composition_style: document.getElementById("composition_style").value,
    overlay_line_color: document.getElementById("overlay_line_color").value,
    overlay_line_width: document.getElementById("overlay_line_width").value,
    overlay_mask_color: document.getElementById("overlay_mask_color").value,
    overlay_mask_alpha: document.getElementById("overlay_mask_alpha").value,
    penetration_offset: document.getElementById("penetration_offset").value,
    align_enable_two_point_perspective: document.getElementById("align_enable_two_point_perspective").checked
  };
}

async function loadSettings() {
  const payload = await requestBridge("camWheelReady");
  if (payload) {
    applyPayload(payload);
  }
}

document.getElementById("save").addEventListener("click", async () => {
  const payload = await requestBridge("camWheelSave", collectPayload());
  if (payload) {
    applyPayload(payload);
  }
});

document.getElementById("reset").addEventListener("click", async () => {
  const payload = await requestBridge("camWheelReset");
  if (payload) {
    applyPayload(payload);
  }
});

loadSettings();
