// import { app } from "@/constants/firebaseConfig";
// import {
//   collection,
//   getDocs,
//   getFirestore,
//   limit,
//   orderBy,
//   query,
//   where,
// } from "firebase/firestore";

export type ServiceStatus = "inReview" | "approved" | "rejected" | "expired";

export type ServiceContactInfo = {
  emailAddress: string;
  phoneNumber: string;
  websiteURL: string;
  facebook: string;
  instagram: string;
  location: string;
};

export type Service = {
  id: string;
  description: string;
  businessName: string;
  contactInfo: ServiceContactInfo;
  ownerID: string;
  status: ServiceStatus;
  expirationDate: number;
  createdAt: number;
  lastUpdatedAt: number;
};

const defaultContactInfo: ServiceContactInfo = {
  emailAddress: "",
  phoneNumber: "",
  websiteURL: "",
  facebook: "",
  instagram: "",
  location: "",
};

function toNumber(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function toServiceStatus(status: string | undefined): ServiceStatus {
  switch (status) {
    case "En Revisi\u00f3n":
      return "inReview";
    case "Aprobado":
      return "approved";
    case "Rechazado":
      return "rejected";
    case "Expirado":
      return "expired";
    default:
      return "inReview";
  }
}

export class ServicesService {
  // private readonly db = getFirestore(app, "prod");

  async loadServices(): Promise<Service[]> {
    return [
      {
        id: "car-wash-top-top",
        businessName: "Car Wash Top Top",
        description:
          "El mejor lugar para limpiar tu coche en el sur de la Florida.",
        contactInfo: {
          emailAddress: "contact@carwashtoptop.com",
          phoneNumber: "+1 305 555 0142",
          websiteURL: "https://carwashtoptop.com",
          facebook: "https://www.facebook.com/carwashtoptop",
          instagram: "https://www.instagram.com/carwashtoptop",
          location: "Miami, Florida, USA",
        },
        ownerID: "mock-owner",
        status: "approved",
        expirationDate: 0,
        createdAt: 1_767_236_800_000,
        lastUpdatedAt: 1_767_236_800_000,
      },
      {
        id: "cafe-habana",
        businessName: "Cafe Habana",
        description:
          "Cafe cubano autentico y pastelitos preparados todos los dias.",
        contactInfo: {
          emailAddress: "contact@cafehabana.com",
          phoneNumber: "+1 786 555 0164",
          websiteURL: "https://www.cafehabana.com",
          facebook: "",
          instagram: "https://www.instagram.com/cafehabana",
          location: "Miami, Florida, USA",
        },
        ownerID: "mock-owner",
        status: "inReview",
        expirationDate: 0,
        createdAt: 1_767_150_400_000,
        lastUpdatedAt: 1_767_150_400_000,
      },
    ];

    // const servicesQuery = query(
    //   collection(this.db, "services"),
    //   where("status", "==", "Aprobado"),
    //   orderBy("createdAt", "desc"),
    //   limit(50),
    // );
    // const snapshot = await getDocs(servicesQuery);
    //
    // return snapshot.docs.map((document) => {
    //   const data = document.data() as Service;
    //   return {
    //     id: document.id,
    //     description: data.description ?? "",
    //     businessName: data.businessName ?? "",
    //     contactInfo: { ...defaultContactInfo, ...data.contactInfo },
    //     ownerID: data.ownerID ?? "",
    //     status: toServiceStatus(data.status),
    //     expirationDate: toNumber(data.expirationDate),
    //     createdAt: toNumber(data.createdAt),
    //     lastUpdatedAt: toNumber(data.lastUpdatedAt),
    //   };
    // });
  }
}

export const servicesService = new ServicesService();
