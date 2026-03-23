const STYLE_LABELS = {
  rule_of_thirds: "九宫格",
  golden_ratio: "黄金分割",
  golden_spiral: "黄金螺旋",
  diagonal: "对角线"
};

const DEFAULT_LABELS = {
  landscape_ratio: "横向比例",
  portrait_ratio: "竖向比例",
  composition_style: "默认线型",
  overlay_line_color: "默认线色",
  overlay_show_label: "默认文字",
  penetration_offset: "默认穿透偏移"
};

function requestBridge(action, payload) {
  if (!window.sketchup || !window.sketchup[action]) {
    return;
  }

  if (payload === undefined) {
    window.sketchup[action]();
  } else {
    window.sketchup[action](JSON.stringify(payload));
  }
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
  renderDefaultsSummary(payload.defaults_summary || {});

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

function renderDefaultsSummary(summary) {
  const container = document.getElementById("defaults_summary");
  container.innerHTML = "";

  Object.entries(summary).forEach(([key, value]) => {
    const item = document.createElement("div");
    item.className = "default-item";
    item.innerHTML = `
      <strong>${DEFAULT_LABELS[key] || key}</strong>
      <span>${formatDefaultValue(key, value)}</span>
    `;
    container.appendChild(item);
  });
}

function formatDefaultValue(key, value) {
  if (key === "composition_style") {
    return STYLE_LABELS[value] || value;
  }
  if (typeof value === "boolean") {
    return value ? "开启" : "关闭";
  }
  return String(value);
}

let noticeTimer = null;

function clearNotice() {
  const notice = document.getElementById("notice");
  if (!notice) {
    return;
  }

  if (noticeTimer) {
    window.clearTimeout(noticeTimer);
    noticeTimer = null;
  }

  notice.classList.remove("is-visible");
  notice.textContent = "";
}

function showNotice(message) {
  const notice = document.getElementById("notice");
  notice.textContent = message;
  notice.classList.add("is-visible");

  if (noticeTimer) {
    window.clearTimeout(noticeTimer);
  }

  noticeTimer = window.setTimeout(clearNotice, 1800);
}

function collectPayload() {
  return {
    composition_ratio_mode: document.getElementById("composition_ratio_mode").value,
    composition_style: document.getElementById("composition_style").value,
    overlay_line_color: document.getElementById("overlay_line_color").value,
    overlay_line_width: document.getElementById("overlay_line_width").value,
    overlay_mask_color: document.getElementById("overlay_mask_color").value,
    overlay_mask_alpha: document.getElementById("overlay_mask_alpha").value,
    overlay_show_label: document.getElementById("overlay_show_label").checked,
    penetration_offset: document.getElementById("penetration_offset").value
  };
}

window.CamWheelSettings = {
  receivePayload(payload) {
    applyPayload(payload);
  },
  showNotice(message) {
    showNotice(message);
  }
};

document.getElementById("save").addEventListener("click", () => {
  requestBridge("camWheelSave", collectPayload());
});

document.getElementById("reset").addEventListener("click", () => {
  requestBridge("camWheelReset");
});

document.addEventListener("visibilitychange", () => {
  if (document.hidden) {
    clearNotice();
  }
});

window.addEventListener("pagehide", clearNotice);

requestBridge("camWheelReady");
