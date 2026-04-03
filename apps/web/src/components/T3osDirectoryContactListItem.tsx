import type { ContactSummary, WorkspaceMemberSummary } from "@si/domain";

interface T3osDirectoryContactListItemProps {
  contact: ContactSummary;
  member: WorkspaceMemberSummary | null;
  isSelected: boolean;
  isAssigned: boolean;
  onSelect: (contactId: string) => void;
}

function getInitials(name: string): string {
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? "")
    .join("");
}

export function T3osDirectoryContactListItem({
  contact,
  member,
  isSelected,
  isAssigned,
  onSelect,
}: T3osDirectoryContactListItemProps) {
  return (
    <button
      type="button"
      className={`directory-contact-item${isSelected ? " selected" : ""}`}
      onClick={() => onSelect(contact.id)}
    >
      <span className="directory-contact-avatar">{getInitials(contact.name)}</span>
      <span className="directory-contact-main">
        <span className="directory-contact-title-row">
          <span className="directory-contact-name">{contact.name}</span>
          {member ? <span className="directory-chip member">Workspace member</span> : null}
          {isAssigned ? <span className="directory-chip assigned">Assigned</span> : null}
        </span>
        <span className="directory-contact-meta">
          {contact.email || "No email on file"}
          {contact.businessName ? ` • ${contact.businessName}` : ""}
          {contact.role ? ` • ${contact.role}` : ""}
        </span>
      </span>
    </button>
  );
}
