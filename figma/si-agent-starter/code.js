const FRAME_WIDTH = 1440;
const FRAME_HEIGHT = 1024;
const FRAME_GAP = 120;

const COLORS = {
  background: { r: 0.953, g: 0.965, b: 0.984 },
  backgroundAccent: { r: 0.925, g: 0.949, b: 0.984 },
  surface: { r: 1, g: 1, b: 1 },
  surfaceMuted: { r: 0.969, g: 0.976, b: 0.988 },
  border: { r: 0.827, g: 0.859, b: 0.91 },
  text: { r: 0.059, g: 0.09, b: 0.165 },
  muted: { r: 0.392, g: 0.455, b: 0.545 },
  brand: { r: 0.145, g: 0.388, b: 0.922 },
  brandDark: { r: 0.114, g: 0.306, b: 0.847 },
  brandSoft: { r: 0.921, g: 0.949, b: 0.992 },
  good: { r: 0.082, g: 0.502, b: 0.239 },
  warning: { r: 0.71, g: 0.325, b: 0.039 },
  bad: { r: 0.725, g: 0.11, b: 0.11 }
};

const fontRequests = [
  { family: "Inter", style: "Regular" },
  { family: "Inter", style: "Medium" },
  { family: "Inter", style: "Semi Bold" },
  { family: "Inter", style: "Bold" }
];

figma.showUI(__html__, {
  width: 360,
  height: 460,
  themeColors: true
});

figma.ui.onmessage = async (message) => {
  try {
    if (message.type === "create-starter") {
      await loadFonts();
      const frames = createStarterSet();
      figma.currentPage.selection = frames;
      figma.viewport.scrollAndZoomIntoView(frames);
      figma.notify("SI Agent starter screens added to the canvas.");
      return;
    }

    if (message.type === "create-screen") {
      await loadFonts();
      const frame = createScreen(message.screenId, 0, 0);
      figma.currentPage.selection = [frame];
      figma.viewport.scrollAndZoomIntoView([frame]);
      figma.notify(`${message.screenId} screen added.`);
      return;
    }

    if (message.type === "close") {
      figma.closePlugin();
    }
  } catch (error) {
    const detail = error instanceof Error ? error.message : "Unknown plugin error";
    figma.notify(detail, { error: true });
  }
};

async function loadFonts() {
  await Promise.all(fontRequests.map((font) => figma.loadFontAsync(font)));
}

function createStarterSet() {
  const screenIds = ["dashboard", "contacts", "initiative", "import", "knowledge"];
  return screenIds.map((screenId, index) =>
    createScreen(screenId, index * (FRAME_WIDTH + FRAME_GAP), 0),
  );
}

function createScreen(screenId, x, y) {
  switch (screenId) {
    case "dashboard":
      return buildDashboardFrame(x, y);
    case "contacts":
      return buildContactsFrame(x, y);
    case "initiative":
      return buildInitiativeFrame(x, y);
    case "import":
      return buildImportFrame(x, y);
    case "knowledge":
      return buildKnowledgeFrame(x, y);
    default:
      throw new Error(`Unknown screen: ${screenId}`);
  }
}

function buildBaseFrame(name, x, y, activeNavLabel = "Dashboard") {
  const frame = figma.createFrame();
  frame.name = name;
  frame.resize(FRAME_WIDTH, FRAME_HEIGHT);
  frame.x = x;
  frame.y = y;
  frame.fills = [
    {
      type: "SOLID",
      color: COLORS.background
    }
  ];

  const sidebar = createCard(20, 20, 232, FRAME_HEIGHT - 40, {
    name: "Sidebar",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 20
  });
  frame.appendChild(sidebar);

  const badge = createBadge(38, 42, "T3OS SI");
  sidebar.appendChild(badge);

  const brand = createTextNode("Strategic Initiatives", 38, 84, {
    fontSize: 24,
    fontName: { family: "Inter", style: "Bold" },
    color: COLORS.text
  });
  sidebar.appendChild(brand);

  const links = ["Dashboard", "Contacts", "Import", "Knowledge", "Initiatives"];
  links.forEach((label, index) => {
    const isActive = label === activeNavLabel;
    const pill = createCard(24, 144 + index * 56, 184, 40, {
      name: `Nav / ${label}`,
      fill: isActive ? COLORS.brand : COLORS.surfaceMuted,
      stroke: isActive ? COLORS.brand : COLORS.surfaceMuted,
      radius: 10
    });
    sidebar.appendChild(pill);
    const text = createTextNode(label, 18, 12, {
      parentRelative: true,
      fontSize: 15,
      fontName: { family: "Inter", style: "Semi Bold" },
      color: isActive ? COLORS.surface : COLORS.muted
    });
    pill.appendChild(text);
  });

  const status = createCard(24, FRAME_HEIGHT - 184, 184, 120, {
    name: "Workspace Meta",
    fill: COLORS.surfaceMuted,
    stroke: COLORS.border,
    radius: 14
  });
  sidebar.appendChild(status);
  status.appendChild(
    createTextNode("Workspace", 16, 16, {
      parentRelative: true,
      fontSize: 12,
      fontName: { family: "Inter", style: "Semi Bold" },
      color: COLORS.muted
    }),
  );
  status.appendChild(
    createTextNode("Executive Review", 16, 38, {
      parentRelative: true,
      fontSize: 18,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );
  status.appendChild(
    createTextNode("8 active initiatives", 16, 72, {
      parentRelative: true,
      fontSize: 14,
      color: COLORS.muted
    }),
  );

  const main = createCard(272, 20, FRAME_WIDTH - 292, FRAME_HEIGHT - 40, {
    name: "Main",
    fill: COLORS.backgroundAccent,
    stroke: COLORS.backgroundAccent,
    radius: 24
  });
  frame.appendChild(main);

  return { frame, main };
}

function buildDashboardFrame(x, y) {
  const { frame, main } = buildBaseFrame("SI Agent / Dashboard", x, y, "Dashboard");

  const hero = createCard(32, 32, main.width - 64, 168, {
    name: "Hero",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(hero);

  hero.appendChild(
    createTextNode("Portfolio Health at a Glance", 28, 24, {
      parentRelative: true,
      fontSize: 30,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );
  hero.appendChild(
    createTextNode(
      "Rank initiatives, inspect evidence, and launch a full refresh from one executive view.",
      28,
      66,
      {
        parentRelative: true,
        fontSize: 16,
        color: COLORS.muted
      },
    ),
  );

  const primary = createButton(28, 108, 176, 40, "Launch Refresh", true);
  hero.appendChild(primary);
  hero.appendChild(createButton(216, 108, 180, 40, "Recompute Ranking", false));

  const statY = 228;
  const statWidth = 208;
  const statGap = 18;
  const stats = [
    ["Active initiatives", "8", COLORS.brandSoft, COLORS.brandDark],
    ["Needs attention", "3", tint(COLORS.warning, 0.84), COLORS.warning],
    ["Reviewed today", "5", tint(COLORS.good, 0.86), COLORS.good],
    ["Top priority", "SI-104", tint(COLORS.bad, 0.88), COLORS.bad]
  ];
  stats.forEach(([label, value, fill, accent], index) => {
    const card = createCard(
      32 + index * (statWidth + statGap),
      statY,
      statWidth,
      118,
      {
        name: `Stat / ${label}`,
        fill,
        stroke: fill,
        radius: 16
      },
    );
    main.appendChild(card);
    card.appendChild(
      createTextNode(label, 18, 18, {
        parentRelative: true,
        fontSize: 13,
        fontName: { family: "Inter", style: "Semi Bold" },
        color: COLORS.muted
      }),
    );
    card.appendChild(
      createTextNode(value, 18, 46, {
        parentRelative: true,
        fontSize: 34,
        fontName: { family: "Inter", style: "Bold" },
        color: accent
      }),
    );
  });

  const table = createCard(32, 372, main.width - 64, 580, {
    name: "Priority Table",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(table);
  table.appendChild(
    createTextNode("Initiative ranking", 24, 22, {
      parentRelative: true,
      fontSize: 22,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );

  const columns = ["Code", "Title", "Group", "Stage", "Status"];
  columns.forEach((column, index) => {
    table.appendChild(
      createTextNode(column, 28 + index * 170, 70, {
        parentRelative: true,
        fontSize: 12,
        fontName: { family: "Inter", style: "Semi Bold" },
        color: COLORS.muted
      }),
    );
  });

  const rows = [
    ["SI-104", "Fleet Readiness", "Ops", "Execution", "At risk"],
    ["SI-087", "Route Margin", "Finance", "Pilot", "Healthy"],
    ["SI-066", "Tech Enablement", "IT", "Review", "Stalled"],
    ["SI-021", "Demand Capture", "Growth", "Execution", "Healthy"]
  ];
  rows.forEach((row, index) => {
    const yOffset = 108 + index * 102;
    const rowCard = createCard(20, yOffset, table.width - 40, 84, {
      name: `Row / ${row[0]}`,
      fill: index % 2 === 0 ? COLORS.surfaceMuted : COLORS.surface,
      stroke: COLORS.border,
      radius: 14
    });
    table.appendChild(rowCard);

    row.forEach((value, columnIndex) => {
      rowCard.appendChild(
        createTextNode(value, 20 + columnIndex * 170, 28, {
          parentRelative: true,
          fontSize: columnIndex === 1 ? 15 : 14,
          fontName: {
            family: "Inter",
            style: columnIndex === 0 || columnIndex === 1 ? "Semi Bold" : "Regular"
          },
          color:
            columnIndex === 4
              ? value === "Healthy"
                ? COLORS.good
                : value === "At risk"
                  ? COLORS.warning
                  : COLORS.bad
              : COLORS.text
        }),
      );
    });
  });

  return frame;
}

function buildContactsFrame(x, y) {
  const { frame, main } = buildBaseFrame("SI Agent / Contacts", x, y, "Contacts");

  const hero = createCard(32, 32, main.width - 64, 156, {
    name: "Contacts Hero",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(hero);
  hero.appendChild(
    createTextNode("Contacts", 28, 24, {
      parentRelative: true,
      fontSize: 30,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );
  hero.appendChild(
    createTextNode(
      "Mirror the T3OS contacts directory with shared search, filter, and table or card views for workspace people and businesses.",
      28,
      68,
      {
        parentRelative: true,
        fontSize: 16,
        color: COLORS.muted,
        width: hero.width - 56,
        lineHeight: 24
      },
    ),
  );
  hero.appendChild(createBadge(28, 112, "T3OS"));
  hero.appendChild(createBadge(124, 112, "Workspace Directory"));
  hero.appendChild(createButton(hero.width - 220, 102, 192, 40, "Refresh Directory", true));

  const statY = 216;
  const statWidth = 278;
  const statGap = 18;
  const stats = [
    ["Total Contacts", "143", COLORS.brandSoft, COLORS.brandDark],
    ["Individuals", "96", tint({ r: 0.486, g: 0.227, b: 0.918 }, 0.86), { r: 0.427, g: 0.157, b: 0.851 }],
    ["Businesses", "47", tint(COLORS.brand, 0.88), COLORS.brand]
  ];
  stats.forEach(([label, value, fill, accent], index) => {
    const card = createCard(
      32 + index * (statWidth + statGap),
      statY,
      statWidth,
      112,
      {
        name: `Contacts Stat / ${label}`,
        fill,
        stroke: fill,
        radius: 16
      },
    );
    main.appendChild(card);
    card.appendChild(
      createTextNode(label, 18, 18, {
        parentRelative: true,
        fontSize: 13,
        fontName: { family: "Inter", style: "Semi Bold" },
        color: COLORS.muted
      }),
    );
    card.appendChild(
      createTextNode(value, 18, 46, {
        parentRelative: true,
        fontSize: 32,
        fontName: { family: "Inter", style: "Bold" },
        color: accent
      }),
    );
  });

  const toolbar = createCard(32, 356, main.width - 64, 88, {
    name: "Contacts Toolbar",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(toolbar);
  toolbar.appendChild(createInput(20, 20, 386, "Search by name, email, role, business, or address"));
  toolbar.appendChild(createButton(428, 20, 104, 48, "All", true));
  toolbar.appendChild(createButton(544, 20, 126, 48, "Individuals", false));
  toolbar.appendChild(createButton(682, 20, 118, 48, "Businesses", false));
  toolbar.appendChild(createButton(toolbar.width - 236, 20, 96, 48, "Table", true));
  toolbar.appendChild(createButton(toolbar.width - 128, 20, 96, 48, "Grid", false));

  const cards = [
    {
      name: "Mark Wopata",
      type: "Person",
      subtitle: "Executive participant",
      primary: "mark@equipmentshare.com",
      secondary: "PM",
      accent: "person"
    },
    {
      name: "Fleet Ops West",
      type: "Business",
      subtitle: "Business contact",
      primary: "Houston, TX",
      secondary: "Branch network",
      accent: "business"
    },
    {
      name: "Alex Rivera",
      type: "Person",
      subtitle: "Regional operator",
      primary: "alex.rivera@equipmentshare.com",
      secondary: "Ops Lead",
      accent: "person"
    }
  ];
  cards.forEach((item, index) => {
    const card = createCard(32 + index * 290, 474, 272, 246, {
      name: `Contact Card / ${item.name}`,
      fill: COLORS.surface,
      stroke: COLORS.border,
      radius: 18
    });
    main.appendChild(card);

    const avatarColor =
      item.accent === "person"
        ? { r: 0.486, g: 0.227, b: 0.918 }
        : { r: 0.145, g: 0.388, b: 0.922 };
    const avatar = createCard(20, 20, 56, 56, {
      name: `Avatar / ${item.name}`,
      fill: avatarColor,
      stroke: avatarColor,
      radius: 16
    });
    card.appendChild(avatar);
    avatar.appendChild(
      createTextNode(getInitialsForDesign(item.name), 16, 17, {
        parentRelative: true,
        fontSize: 18,
        fontName: { family: "Inter", style: "Bold" },
        color: COLORS.surface
      }),
    );

    card.appendChild(
      createTextNode(item.name, 92, 22, {
        parentRelative: true,
        fontSize: 20,
        fontName: { family: "Inter", style: "Bold" },
        color: COLORS.text,
        width: 160,
        lineHeight: 24
      }),
    );
    card.appendChild(
      createTextNode(item.subtitle, 92, 52, {
        parentRelative: true,
        fontSize: 13,
        color: COLORS.muted
      }),
    );

    const pillColor =
      item.accent === "person"
        ? tint({ r: 0.486, g: 0.227, b: 0.918 }, 0.88)
        : tint(COLORS.brand, 0.9);
    const pillText =
      item.accent === "person"
        ? { r: 0.427, g: 0.157, b: 0.851 }
        : COLORS.brandDark;
    const pill = createCard(20, 96, 90, 28, {
      name: `Pill / ${item.type}`,
      fill: pillColor,
      stroke: pillColor,
      radius: 999
    });
    card.appendChild(pill);
    pill.appendChild(
      createTextNode(item.type, 18, 7, {
        parentRelative: true,
        fontSize: 11,
        fontName: { family: "Inter", style: "Bold" },
        color: pillText
      }),
    );

    [
      ["Primary", item.primary],
      ["Context", item.secondary],
      ["Updated", "Apr 3, 2026"]
    ].forEach(([label, value], detailIndex) => {
      card.appendChild(
        createTextNode(label, 20, 144 + detailIndex * 32, {
          parentRelative: true,
          fontSize: 11,
          fontName: { family: "Inter", style: "Semi Bold" },
          color: COLORS.muted
        }),
      );
      card.appendChild(
        createTextNode(value, 88, 142 + detailIndex * 32, {
          parentRelative: true,
          fontSize: 13,
          color: COLORS.text,
          width: 160,
          lineHeight: 18
        }),
      );
    });
  });

  const table = createCard(32, 748, main.width - 64, 204, {
    name: "Contacts Table",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(table);
  ["Name", "Type", "Role / Business", "Email / Phone", "Updated"].forEach((label, index) => {
    table.appendChild(
      createTextNode(label, 28 + index * 170, 24, {
        parentRelative: true,
        fontSize: 12,
        fontName: { family: "Inter", style: "Semi Bold" },
        color: COLORS.muted
      }),
    );
  });

  const rowData = [
    ["Mark Wopata", "Person", "PM", "mark@equipmentshare.com", "Apr 3"],
    ["Fleet Ops West", "Business", "Houston, TX", "No email", "Apr 2"]
  ];
  rowData.forEach((row, rowIndex) => {
    const rowCard = createCard(20, 56 + rowIndex * 64, table.width - 40, 48, {
      name: `Table Row / ${row[0]}`,
      fill: rowIndex === 0 ? COLORS.surfaceMuted : COLORS.surface,
      stroke: COLORS.border,
      radius: 12
    });
    table.appendChild(rowCard);
    row.forEach((value, columnIndex) => {
      rowCard.appendChild(
        createTextNode(value, 18 + columnIndex * 170, 15, {
          parentRelative: true,
          fontSize: 13,
          fontName: { family: "Inter", style: columnIndex === 0 ? "Semi Bold" : "Regular" },
          color: COLORS.text
        }),
      );
    });
  });

  return frame;
}

function buildInitiativeFrame(x, y) {
  const { frame, main } = buildBaseFrame("SI Agent / Initiative Detail", x, y, "Initiatives");

  const hero = createCard(32, 32, main.width - 64, 164, {
    name: "Initiative Hero",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(hero);
  hero.appendChild(createBadge(28, 24, "SI-104"));
  hero.appendChild(
    createTextNode("Fleet Readiness Recovery", 28, 70, {
      parentRelative: true,
      fontSize: 30,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );
  hero.appendChild(
    createTextNode(
      "Operational initiative focused on cutting downtime, parts delays, and service bottlenecks.",
      28,
      112,
      {
        parentRelative: true,
        fontSize: 16,
        color: COLORS.muted
      },
    ),
  );

  const left = createCard(32, 222, 420, 730, {
    name: "Evidence Rail",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(left);
  left.appendChild(
    createTextNode("Evidence and sources", 24, 22, {
      parentRelative: true,
      fontSize: 22,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );

  const evidence = [
    ["Slack", "Field ops reported rising backlog in Houston and Dallas."],
    ["Workbook", "Throughput is 17% below target for March."],
    ["Google Drive", "Corrective action deck proposes branch-level staffing changes."]
  ];
  evidence.forEach(([source, detail], index) => {
    const block = createCard(20, 72 + index * 176, left.width - 40, 148, {
      name: `Evidence / ${source}`,
      fill: COLORS.surfaceMuted,
      stroke: COLORS.border,
      radius: 14
    });
    left.appendChild(block);
    block.appendChild(
      createTextNode(source, 18, 16, {
        parentRelative: true,
        fontSize: 14,
        fontName: { family: "Inter", style: "Semi Bold" },
        color: COLORS.brandDark
      }),
    );
    block.appendChild(
      createTextNode(detail, 18, 48, {
        parentRelative: true,
        fontSize: 15,
        color: COLORS.text,
        width: block.width - 36,
        lineHeight: 24
      }),
    );
  });

  const right = createCard(476, 222, main.width - 508, 730, {
    name: "Opinion Panel",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(right);
  right.appendChild(
    createTextNode("Latest opinion", 24, 22, {
      parentRelative: true,
      fontSize: 22,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );

  const scoreCard = createCard(24, 72, right.width - 48, 96, {
    name: "Score",
    fill: tint(COLORS.warning, 0.88),
    stroke: tint(COLORS.warning, 0.88),
    radius: 16
  });
  right.appendChild(scoreCard);
  scoreCard.appendChild(
    createTextNode("Needs attention", 20, 18, {
      parentRelative: true,
      fontSize: 16,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.warning
    }),
  );
  scoreCard.appendChild(
    createTextNode("Operational drag has persisted for 3 weeks without a confirmed recovery owner.", 20, 46, {
      parentRelative: true,
      fontSize: 14,
      color: COLORS.text,
      width: scoreCard.width - 40,
      lineHeight: 20
    }),
  );

  const themes = [
    "Dispatch sequencing is improving slower than planned.",
    "Parts shortages are concentrated in two high-volume regions.",
    "Executive sponsor engagement is strong, but regional follow-through varies."
  ];
  themes.forEach((theme, index) => {
    const row = createCard(24, 196 + index * 108, right.width - 48, 84, {
      name: `Theme / ${index + 1}`,
      fill: COLORS.surfaceMuted,
      stroke: COLORS.border,
      radius: 14
    });
    right.appendChild(row);
    row.appendChild(
      createTextNode(`Signal ${index + 1}`, 18, 16, {
        parentRelative: true,
        fontSize: 12,
        fontName: { family: "Inter", style: "Semi Bold" },
        color: COLORS.muted
      }),
    );
    row.appendChild(
      createTextNode(theme, 18, 38, {
        parentRelative: true,
        fontSize: 14,
        color: COLORS.text,
        width: row.width - 36,
        lineHeight: 20
      }),
    );
  });

  return frame;
}

function buildImportFrame(x, y) {
  const { frame, main } = buildBaseFrame("SI Agent / Workbook Import", x, y, "Import");

  const intro = createCard(32, 32, main.width - 64, 160, {
    name: "Import Hero",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(intro);
  intro.appendChild(
    createTextNode("Import Strategic Initiatives Workbook", 28, 24, {
      parentRelative: true,
      fontSize: 28,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );
  intro.appendChild(
    createTextNode(
      "Load the default workbook from disk or upload a fresh version to refresh the initiative registry.",
      28,
      66,
      {
        parentRelative: true,
        fontSize: 16,
        color: COLORS.muted,
        width: intro.width - 56,
        lineHeight: 24
      },
    ),
  );
  intro.appendChild(createButton(28, 108, 204, 40, "Import Default Workbook", true));
  intro.appendChild(createButton(246, 108, 148, 40, "Upload File", false));

  const form = createCard(32, 222, 450, 330, {
    name: "Import Form",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(form);
  form.appendChild(
    createTextNode("Workbook source", 24, 24, {
      parentRelative: true,
      fontSize: 20,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );
  form.appendChild(createInput(24, 78, form.width - 48, "Default path: /Users/.../SI.xlsx"));
  form.appendChild(createInput(24, 146, form.width - 48, "Manual upload"));
  form.appendChild(createButton(24, 234, 156, 40, "Run Import", true));

  const summary = createCard(516, 222, main.width - 548, 330, {
    name: "Import Summary",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(summary);
  summary.appendChild(
    createTextNode("Import summary", 24, 24, {
      parentRelative: true,
      fontSize: 20,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );
  const summaryStats = [
    ["Batch", "B-2026-04-03"],
    ["Imported", "43"],
    ["Skipped", "4"]
  ];
  summaryStats.forEach(([label, value], index) => {
    const card = createCard(24 + index * 170, 82, 150, 110, {
      name: `Summary / ${label}`,
      fill: COLORS.surfaceMuted,
      stroke: COLORS.border,
      radius: 14
    });
    summary.appendChild(card);
    card.appendChild(
      createTextNode(label, 16, 16, {
        parentRelative: true,
        fontSize: 12,
        fontName: { family: "Inter", style: "Semi Bold" },
        color: COLORS.muted
      }),
    );
    card.appendChild(
      createTextNode(value, 16, 48, {
        parentRelative: true,
        fontSize: 20,
        fontName: { family: "Inter", style: "Bold" },
        color: COLORS.text
      }),
    );
  });

  const warnings = createCard(32, 584, main.width - 64, 368, {
    name: "Warnings",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(warnings);
  warnings.appendChild(
    createTextNode("Warnings and review notes", 24, 24, {
      parentRelative: true,
      fontSize: 20,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );
  [
    "Two initiatives were missing objective text and were skipped.",
    "Owner names were normalized to the current roster.",
    "One duplicate initiative code was merged with the latest workbook row."
  ].forEach((warning, index) => {
    warnings.appendChild(
      createBulletRow(24, 82 + index * 78, warnings.width - 48, warning),
    );
  });

  return frame;
}

function buildKnowledgeFrame(x, y) {
  const { frame, main } = buildBaseFrame("SI Agent / Knowledge View", x, y, "Knowledge");

  const top = createCard(32, 32, main.width - 64, 146, {
    name: "Knowledge Hero",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(top);
  top.appendChild(
    createTextNode("Global Knowledge and Operating Context", 28, 24, {
      parentRelative: true,
      fontSize: 28,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );
  top.appendChild(
    createTextNode(
      "Curated seeds, platform references, and initiative evidence are grouped for faster agent retrieval.",
      28,
      68,
      {
        parentRelative: true,
        fontSize: 16,
        color: COLORS.muted,
        width: top.width - 56,
        lineHeight: 24
      },
    ),
  );

  const left = createCard(32, 210, 360, 742, {
    name: "Knowledge Rail",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(left);
  left.appendChild(
    createTextNode("Collections", 24, 24, {
      parentRelative: true,
      fontSize: 20,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );
  ["Global operating model", "Initiative seeds", "Document extracts", "Platform references"].forEach(
    (label, index) => {
      const pill = createCard(20, 76 + index * 70, left.width - 40, 52, {
        name: `Collection / ${label}`,
        fill: index === 0 ? COLORS.brandSoft : COLORS.surfaceMuted,
        stroke: COLORS.border,
        radius: 14
      });
      left.appendChild(pill);
      pill.appendChild(
        createTextNode(label, 16, 17, {
          parentRelative: true,
          fontSize: 15,
          fontName: { family: "Inter", style: "Semi Bold" },
          color: index === 0 ? COLORS.brandDark : COLORS.text
        }),
      );
    },
  );

  const content = createCard(426, 210, main.width - 458, 742, {
    name: "Knowledge Content",
    fill: COLORS.surface,
    stroke: COLORS.border,
    radius: 18
  });
  main.appendChild(content);
  content.appendChild(
    createTextNode("Strategic Initiative operating model", 24, 24, {
      parentRelative: true,
      fontSize: 24,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.text
    }),
  );
  content.appendChild(
    createTextNode(
      "The SI agent combines workbook structure, evidence ingestion, ranking, and opinion generation into a single local-first platform. This canvas shows where those curated knowledge assets live and how they support reviews.",
      24,
      72,
      {
        parentRelative: true,
        fontSize: 16,
        color: COLORS.text,
        width: content.width - 48,
        lineHeight: 26
      },
    ),
  );

  [
    "Knowledge seeds give the agent global context before initiative-specific reasoning starts.",
    "Document extracts preserve source evidence for audit trails and answer grounding.",
    "Platform references connect T3OS concepts and external operating assumptions."
  ].forEach((line, index) => {
    content.appendChild(
      createBulletRow(24, 214 + index * 82, content.width - 48, line),
    );
  });

  return frame;
}

function createBadge(x, y, label) {
  const badge = createCard(x, y, 86, 28, {
    name: `Badge / ${label}`,
    fill: COLORS.brandSoft,
    stroke: COLORS.brandSoft,
    radius: 999
  });
  badge.appendChild(
    createTextNode(label, 12, 7, {
      parentRelative: true,
      fontSize: 11,
      fontName: { family: "Inter", style: "Bold" },
      color: COLORS.brandDark
    }),
  );
  return badge;
}

function createButton(x, y, width, height, label, primary) {
  const button = createCard(x, y, width, height, {
    name: `Button / ${label}`,
    fill: primary ? COLORS.brand : COLORS.surface,
    stroke: primary ? COLORS.brand : COLORS.border,
    radius: 10
  });
  button.appendChild(
    createTextNode(label, 16, 11, {
      parentRelative: true,
      fontSize: 14,
      fontName: { family: "Inter", style: "Semi Bold" },
      color: primary ? COLORS.surface : COLORS.text
    }),
  );
  return button;
}

function getInitialsForDesign(name) {
  return name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? "")
    .join("");
}

function createInput(x, y, width, label) {
  const input = createCard(x, y, width, 48, {
    name: `Input / ${label}`,
    fill: COLORS.surfaceMuted,
    stroke: COLORS.border,
    radius: 12
  });
  input.appendChild(
    createTextNode(label, 16, 15, {
      parentRelative: true,
      fontSize: 14,
      color: COLORS.muted
    }),
  );
  return input;
}

function createBulletRow(x, y, width, text) {
  const row = figma.createFrame();
  row.name = `Bullet / ${text.slice(0, 18)}`;
  row.x = x;
  row.y = y;
  row.resize(width, 58);
  row.fills = [];
  row.strokes = [];

  const dot = figma.createEllipse();
  dot.resize(10, 10);
  dot.x = 0;
  dot.y = 10;
  dot.fills = [{ type: "SOLID", color: COLORS.brand }];
  row.appendChild(dot);

  row.appendChild(
    createTextNode(text, 26, 0, {
      parentRelative: true,
      fontSize: 15,
      color: COLORS.text,
      width: width - 26,
      lineHeight: 24
    }),
  );

  return row;
}

function createCard(x, y, width, height, options) {
  const rect = figma.createFrame();
  rect.name = options.name;
  rect.x = x;
  rect.y = y;
  rect.resize(width, height);
  rect.cornerRadius = options.radius;
  rect.fills = [{ type: "SOLID", color: options.fill }];
  rect.strokes = [{ type: "SOLID", color: options.stroke }];
  rect.strokeWeight = 1;
  rect.clipsContent = false;
  return rect;
}

function createTextNode(text, x, y, options) {
  const node = figma.createText();
  node.name = text.slice(0, 32);
  node.fontName = options.fontName || { family: "Inter", style: "Regular" };
  node.fontSize = options.fontSize;
  node.characters = text;
  node.x = x;
  node.y = y;
  node.fills = [{ type: "SOLID", color: options.color }];
  if (options.width) {
    node.textAutoResize = "HEIGHT";
    node.resize(options.width, node.height);
  } else {
    node.textAutoResize = "WIDTH_AND_HEIGHT";
  }
  if (options.lineHeight) {
    node.lineHeight = { unit: "PIXELS", value: options.lineHeight };
  }
  return node;
}

function tint(color, amount) {
  return {
    r: color.r * (1 - amount) + amount,
    g: color.g * (1 - amount) + amount,
    b: color.b * (1 - amount) + amount
  };
}
