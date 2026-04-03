import type {
  ContactSummary,
  CreateOrUpdateContactInput,
  InitiativeDetail,
  UpdateContactInput,
  WorkspaceMemberSummary,
} from "@si/domain";
import { env } from "../config/env.js";

type GraphqlResponse<T> = {
  data?: T;
  errors?: Array<{ message?: string }>;
};

const LIST_CONTACTS_QUERY = `
  query SiPlatformListContacts($workspaceId: String!, $contactType: ContactType) {
    listContacts(filter: { workspaceId: $workspaceId, contactType: $contactType }, page: { size: 250 }) {
      items {
        __typename
        ... on PersonContact {
          id
          workspaceId
          contactType
          name
          email
          phone
          role
          businessId
          business { id name }
          createdAt
          updatedAt
        }
        ... on BusinessContact {
          id
          workspaceId
          contactType
          name
          phone
          address
          createdAt
          updatedAt
        }
      }
    }
  }
`;

const LIST_WORKSPACE_MEMBERS_QUERY = `
  query SiPlatformWorkspaceMembers($workspaceId: String!) {
    listWorkspaceMembers(workspaceId: $workspaceId) {
      items {
        userId
        roles
        user {
          id
          email
        }
      }
    }
  }
`;

const CREATE_PERSON_CONTACT_MUTATION = `
  mutation SiPlatformCreatePersonContact(
    $workspaceId: String!
    $name: String!
    $email: String!
    $phone: String
    $role: String
    $businessId: ID!
    $resourceMapIds: [ID!]
  ) {
    createPersonContact(
      input: {
        workspaceId: $workspaceId
        name: $name
        email: $email
        phone: $phone
        role: $role
        businessId: $businessId
        resourceMapIds: $resourceMapIds
      }
    ) {
      id
      workspaceId
      contactType
      name
      email
      phone
      role
      businessId
      business { id name }
      createdAt
      updatedAt
    }
  }
`;

const UPDATE_PERSON_CONTACT_MUTATION = `
  mutation SiPlatformUpdatePersonContact($id: ID!, $input: UpdatePersonContactInput!) {
    updatePersonContact(id: $id, input: $input) {
      id
      workspaceId
      contactType
      name
      email
      phone
      role
      businessId
      business { id name }
      createdAt
      updatedAt
    }
  }
`;

const CREATE_BUSINESS_CONTACT_MUTATION = `
  mutation SiPlatformCreateBusinessContact(
    $workspaceId: String!
    $name: String!
    $phone: String
    $address: String
    $taxId: String!
    $website: String
    $brandId: ID
    $latitude: Float
    $longitude: Float
    $placeId: String
  ) {
    createBusinessContact(
      input: {
        workspaceId: $workspaceId
        name: $name
        phone: $phone
        address: $address
        taxId: $taxId
        website: $website
        brandId: $brandId
        latitude: $latitude
        longitude: $longitude
        placeId: $placeId
      }
    ) {
      id
      workspaceId
      contactType
      name
      phone
      address
      createdAt
      updatedAt
    }
  }
`;

const UPDATE_BUSINESS_CONTACT_MUTATION = `
  mutation SiPlatformUpdateBusinessContact($id: ID!, $input: UpdateBusinessContactInput!) {
    updateBusinessContact(id: $id, input: $input) {
      id
      workspaceId
      contactType
      name
      phone
      address
      createdAt
      updatedAt
    }
  }
`;

const INVITE_WORKSPACE_MEMBER_MUTATION = `
  mutation SiPlatformInviteWorkspaceMember($workspaceId: String!, $email: String!, $roles: [WorkspaceUserRole!]!) {
    inviteUserToWorkspace(workspaceId: $workspaceId, email: $email, roles: $roles) {
      userId
      roles
      user {
        id
        email
      }
    }
  }
`;

const UPDATE_WORKSPACE_MEMBER_ROLES_MUTATION = `
  mutation SiPlatformUpdateWorkspaceMemberRoles($workspaceId: String!, $userId: String!, $roles: [WorkspaceUserRole!]!) {
    updateWorkspaceUserRoles(workspaceId: $workspaceId, userId: $userId, roles: $roles) {
      userId
      roles
      user {
        id
        email
      }
    }
  }
`;

const REMOVE_WORKSPACE_MEMBER_MUTATION = `
  mutation SiPlatformRemoveWorkspaceMember($workspaceId: String!, $userId: String!) {
    removeUserFromWorkspace(workspaceId: $workspaceId, userId: $userId)
  }
`;

function operationUrl(operationName: string): string {
  const base = env.T3OS_GRAPHQL_URL;
  return base.includes("?") ? `${base}&op=${encodeURIComponent(operationName)}` : `${base}?op=${encodeURIComponent(operationName)}`;
}

async function executeT3osGraphql<T>(
  token: string,
  operationName: string,
  query: string,
  variables: Record<string, unknown>,
): Promise<T> {
  const response = await fetch(operationUrl(operationName), {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      operationName,
      query,
      variables,
    }),
  });

  const payload = (await response.json()) as GraphqlResponse<T>;
  if (!response.ok) {
    throw new Error(payload.errors?.map((error) => error.message).filter(Boolean).join("; ") || `T3OS GraphQL request failed with HTTP ${response.status}`);
  }

  if (payload.errors?.length) {
    throw new Error(payload.errors.map((error) => error.message).filter(Boolean).join("; "));
  }

  if (!payload.data) {
    throw new Error("T3OS GraphQL returned no data");
  }

  return payload.data;
}

function normalizeContact(raw: Record<string, unknown>): ContactSummary {
  const business = raw.business && typeof raw.business === "object" ? (raw.business as Record<string, unknown>) : null;
  return {
    id: String(raw.id ?? ""),
    contactType: raw.contactType === "BUSINESS" ? "BUSINESS" : "PERSON",
    workspaceId: String(raw.workspaceId ?? ""),
    name: String(raw.name ?? ""),
    email: typeof raw.email === "string" ? raw.email : null,
    phone: typeof raw.phone === "string" ? raw.phone : null,
    role: typeof raw.role === "string" ? raw.role : null,
    businessId: typeof raw.businessId === "string" ? raw.businessId : null,
    businessName: typeof business?.name === "string" ? String(business.name) : null,
    address: typeof raw.address === "string" ? raw.address : null,
    updatedAt: typeof raw.updatedAt === "string" ? raw.updatedAt : null,
    createdAt: typeof raw.createdAt === "string" ? raw.createdAt : null,
  };
}

function normalizeWorkspaceMember(raw: Record<string, unknown>): WorkspaceMemberSummary {
  const user = raw.user && typeof raw.user === "object" ? (raw.user as Record<string, unknown>) : null;
  return {
    userId: String(raw.userId ?? ""),
    roles: Array.isArray(raw.roles) ? raw.roles.map((role) => String(role)) : [],
    user: user
      ? {
          id: String(user.id ?? raw.userId ?? ""),
          name: null,
          email: typeof user.email === "string" ? user.email : null,
        }
      : null,
  };
}

export function hydrateInitiativePeopleFromDirectory(input: {
  people: InitiativeDetail["people"];
  contacts: ContactSummary[];
  members: WorkspaceMemberSummary[];
}): InitiativeDetail["people"] {
  const contactsById = new Map(input.contacts.map((contact) => [contact.id, contact] as const));
  const membersByUserId = new Map<string, WorkspaceMemberSummary>();
  for (const member of input.members) {
    membersByUserId.set(member.userId, member);
    if (member.user?.id) {
      membersByUserId.set(member.user.id, member);
    }
  }

  return input.people.map((person) => {
    const isT3osBacked =
      person.sourceType === "t3os" ||
      Boolean(person.t3osContactId || person.t3osWorkspaceMemberId || person.t3osUserId);

    if (!isT3osBacked) {
      return {
        ...person,
        directorySource: "legacy_local" as const,
        directoryResolved: true,
      };
    }

    const contact = person.t3osContactId ? contactsById.get(person.t3osContactId) ?? null : null;
    const member =
      (person.t3osWorkspaceMemberId
        ? membersByUserId.get(person.t3osWorkspaceMemberId)
        : undefined) ??
      (person.t3osUserId ? membersByUserId.get(person.t3osUserId) : undefined) ??
      null;

    const displayName = contact?.name ?? member?.user?.email ?? "";
    const email = contact?.email ?? member?.user?.email ?? null;
    const directoryResolved = Boolean(contact || member?.user?.email);

    return {
      ...person,
      displayName,
      email,
      directorySource: "t3os" as const,
      directoryResolved,
    };
  });
}

export async function hydrateInitiativePeopleFromT3os(input: {
  token: string;
  workspaceId: string;
  people: InitiativeDetail["people"];
}): Promise<InitiativeDetail["people"]> {
  const [contacts, members] = await Promise.all([
    listPlatformContacts({
      token: input.token,
      workspaceId: input.workspaceId,
      contactType: "PERSON",
    }),
    listPlatformWorkspaceMembers({
      token: input.token,
      workspaceId: input.workspaceId,
    }),
  ]);

  return hydrateInitiativePeopleFromDirectory({
    people: input.people,
    contacts,
    members,
  });
}

export async function listPlatformContacts(input: {
  token: string;
  workspaceId: string;
  contactType?: "PERSON" | "BUSINESS";
}): Promise<ContactSummary[]> {
  const data = await executeT3osGraphql<{
    listContacts: {
      items: Record<string, unknown>[];
    };
  }>(input.token, "SiPlatformListContacts", LIST_CONTACTS_QUERY, {
    workspaceId: input.workspaceId,
    contactType: input.contactType ?? null,
  });

  return (data.listContacts?.items ?? []).map((item) => normalizeContact(item));
}

export async function listPlatformWorkspaceMembers(input: {
  token: string;
  workspaceId: string;
}): Promise<WorkspaceMemberSummary[]> {
  const data = await executeT3osGraphql<{
    listWorkspaceMembers: {
      items: Record<string, unknown>[];
    };
  }>(input.token, "SiPlatformWorkspaceMembers", LIST_WORKSPACE_MEMBERS_QUERY, {
    workspaceId: input.workspaceId,
  });

  return (data.listWorkspaceMembers?.items ?? []).map((item) => normalizeWorkspaceMember(item));
}

export async function createPlatformContact(input: {
  token: string;
  payload: CreateOrUpdateContactInput;
}): Promise<ContactSummary> {
  if (input.payload.contactType === "BUSINESS") {
    const data = await executeT3osGraphql<{
      createBusinessContact: Record<string, unknown>;
    }>(input.token, "SiPlatformCreateBusinessContact", CREATE_BUSINESS_CONTACT_MUTATION, input.payload);
    return normalizeContact(data.createBusinessContact);
  }

  const data = await executeT3osGraphql<{
    createPersonContact: Record<string, unknown>;
  }>(input.token, "SiPlatformCreatePersonContact", CREATE_PERSON_CONTACT_MUTATION, input.payload);
  return normalizeContact(data.createPersonContact);
}

export async function updatePlatformContact(input: {
  token: string;
  contactId: string;
  payload: UpdateContactInput;
}): Promise<ContactSummary> {
  if (input.payload.contactType === "BUSINESS") {
    const data = await executeT3osGraphql<{
      updateBusinessContact: Record<string, unknown>;
    }>(input.token, "SiPlatformUpdateBusinessContact", UPDATE_BUSINESS_CONTACT_MUTATION, {
      id: input.contactId,
      input: {
        ...input.payload,
        contactType: undefined,
      },
    });
    return normalizeContact(data.updateBusinessContact);
  }

  const data = await executeT3osGraphql<{
    updatePersonContact: Record<string, unknown>;
  }>(input.token, "SiPlatformUpdatePersonContact", UPDATE_PERSON_CONTACT_MUTATION, {
    id: input.contactId,
    input: {
      ...input.payload,
      contactType: undefined,
    },
  });
  return normalizeContact(data.updatePersonContact);
}

export async function invitePlatformWorkspaceMember(input: {
  token: string;
  workspaceId: string;
  email: string;
  roles: string[];
}): Promise<WorkspaceMemberSummary> {
  const data = await executeT3osGraphql<{
    inviteUserToWorkspace: Record<string, unknown>;
  }>(input.token, "SiPlatformInviteWorkspaceMember", INVITE_WORKSPACE_MEMBER_MUTATION, {
    workspaceId: input.workspaceId,
    email: input.email,
    roles: input.roles,
  });
  return normalizeWorkspaceMember(data.inviteUserToWorkspace);
}

export async function updatePlatformWorkspaceMemberRoles(input: {
  token: string;
  workspaceId: string;
  userId: string;
  roles: string[];
}): Promise<WorkspaceMemberSummary> {
  const data = await executeT3osGraphql<{
    updateWorkspaceUserRoles: Record<string, unknown>;
  }>(input.token, "SiPlatformUpdateWorkspaceMemberRoles", UPDATE_WORKSPACE_MEMBER_ROLES_MUTATION, {
    workspaceId: input.workspaceId,
    userId: input.userId,
    roles: input.roles,
  });
  return normalizeWorkspaceMember(data.updateWorkspaceUserRoles);
}

export async function removePlatformWorkspaceMember(input: {
  token: string;
  workspaceId: string;
  userId: string;
}): Promise<boolean> {
  const data = await executeT3osGraphql<{
    removeUserFromWorkspace: boolean;
  }>(input.token, "SiPlatformRemoveWorkspaceMember", REMOVE_WORKSPACE_MEMBER_MUTATION, {
    workspaceId: input.workspaceId,
    userId: input.userId,
  });
  return Boolean(data.removeUserFromWorkspace);
}
