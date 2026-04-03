import { describe, expect, it } from "vitest";
import { hydrateInitiativePeopleFromDirectory } from "./t3os-platform-service.js";

describe("hydrateInitiativePeopleFromDirectory", () => {
  it("hydrates T3OS-backed people from T3OS contacts", () => {
    const result = hydrateInitiativePeopleFromDirectory({
      people: [
        {
          id: "person_1",
          role: "initiative_owner",
          displayName: "Stale Local Name",
          email: "stale@example.com",
          t3osContactId: "contact_1",
          t3osWorkspaceMemberId: "member_1",
          t3osUserId: "user_1",
          sourceType: "t3os",
          sortOrder: 0,
        },
      ],
      contacts: [
        {
          id: "contact_1",
          contactType: "PERSON",
          workspaceId: "workspace_1",
          name: "Fresh T3OS Name",
          email: "fresh@example.com",
          phone: null,
          role: null,
          businessId: null,
          businessName: null,
          address: null,
          createdAt: null,
          updatedAt: null,
        },
      ],
      members: [
        {
          userId: "member_1",
          roles: ["VIEWER"],
          user: {
            id: "user_1",
            name: null,
            email: "member@example.com",
          },
        },
      ],
    });

    expect(result[0]?.displayName).toBe("Fresh T3OS Name");
    expect(result[0]?.email).toBe("fresh@example.com");
    expect(result[0]?.directorySource).toBe("t3os");
    expect(result[0]?.directoryResolved).toBe(true);
  });

  it("marks unresolved T3OS-backed people without falling back to stale local data", () => {
    const result = hydrateInitiativePeopleFromDirectory({
      people: [
        {
          id: "person_2",
          role: "sales_lead",
          displayName: "Old Local Name",
          email: "old@example.com",
          t3osContactId: "missing_contact",
          sourceType: "t3os",
          sortOrder: 1,
        },
      ],
      contacts: [],
      members: [],
    });

    expect(result[0]?.displayName).toBe("");
    expect(result[0]?.email).toBeNull();
    expect(result[0]?.directorySource).toBe("t3os");
    expect(result[0]?.directoryResolved).toBe(false);
  });

  it("preserves legacy local assignees", () => {
    const result = hydrateInitiativePeopleFromDirectory({
      people: [
        {
          id: "person_3",
          role: "pm",
          displayName: "Legacy Local",
          email: "legacy@example.com",
          sourceType: "local",
          sortOrder: 2,
        },
      ],
      contacts: [],
      members: [],
    });

    expect(result[0]?.displayName).toBe("Legacy Local");
    expect(result[0]?.email).toBe("legacy@example.com");
    expect(result[0]?.directorySource).toBe("legacy_local");
    expect(result[0]?.directoryResolved).toBe(true);
  });
});
