import { Icon, createIcon } from "@chakra-ui/react";
import { ComponentProps } from "react";

export const VippsIcon = ({
  title,
  ...rest
}: ComponentProps<typeof Icon> & { title?: string }) => (
  <Icon viewBox="0 0 48 14" {...rest}>
    {title && <title>{title}</title>}
    <path
      fill="currentColor"
      d="M2.41205 1.13086L4.4623 7.12079L6.47234 1.13086H8.8442L5.30652 10.0153H3.53768L0 1.13086H2.41205Z"
    />
    <path
      fill="currentColor"
      d="M14.1911 8.60777C15.6785 8.60777 16.5227 7.88415 17.3267 6.83893C17.7689 6.27612 18.3318 6.15551 18.7338 6.47712C19.1358 6.79873 19.176 7.40174 18.7338 7.96455C17.5679 9.49219 16.0805 10.4168 14.1911 10.4168C12.1408 10.4168 10.3318 9.29118 9.08555 7.32134C8.72374 6.79873 8.80414 6.23592 9.20615 5.95451C9.60816 5.6731 10.2112 5.79371 10.573 6.35652C11.4574 7.68315 12.6634 8.60777 14.1911 8.60777ZM16.9649 3.66306C16.9649 4.38667 16.4021 4.86908 15.7589 4.86908C15.1157 4.86908 14.5529 4.38667 14.5529 3.66306C14.5529 2.93944 15.1157 2.45703 15.7589 2.45703C16.4021 2.45703 16.9649 2.97964 16.9649 3.66306Z"
    />
    <path
      fill="currentColor"
      d="M22.6339 1.13085V2.33688C23.2369 1.49266 24.1615 0.889648 25.5284 0.889648C27.257 0.889648 29.267 2.33688 29.267 5.43235C29.267 8.68862 27.3374 10.2565 25.3274 10.2565C24.2821 10.2565 23.3173 9.85445 22.5937 8.84943V13.1107H20.4229V1.13085H22.6339ZM22.6339 5.55295C22.6339 7.36199 23.6791 8.32681 24.8449 8.32681C25.9706 8.32681 27.0962 7.44239 27.0962 5.55295C27.0962 3.70371 25.9706 2.81929 24.8449 2.81929C23.7193 2.81929 22.6339 3.66351 22.6339 5.55295Z"
    />
    <path
      fill="currentColor"
      d="M33.0851 1.13085V2.33688C33.6881 1.49266 34.6127 0.889648 35.9795 0.889648C37.7082 0.889648 39.7182 2.33688 39.7182 5.43235C39.7182 8.68862 37.7886 10.2565 35.7785 10.2565C34.7333 10.2565 33.7685 9.85445 33.0449 8.84943V13.1107H30.874V1.13085H33.0851ZM33.0851 5.55295C33.0851 7.36199 34.1303 8.32681 35.2961 8.32681C36.4217 8.32681 37.5474 7.44239 37.5474 5.55295C37.5474 3.70371 36.4217 2.81929 35.2961 2.81929C34.1303 2.81929 33.0851 3.66351 33.0851 5.55295Z"
    />
    <path
      fill="currentColor"
      d="M44.342 0.889648C46.1511 0.889648 47.4375 1.73387 48.0003 3.82431L46.0305 4.14592C45.9903 3.1007 45.3471 2.73889 44.3822 2.73889C43.6586 2.73889 43.0958 3.0605 43.0958 3.58311C43.0958 3.98512 43.3772 4.38713 44.2214 4.54793L45.7089 4.82934C47.1561 5.11074 47.9601 6.07556 47.9601 7.36199C47.9601 9.29164 46.2315 10.2565 44.5832 10.2565C42.8546 10.2565 40.925 9.37204 40.6436 7.20119L42.6134 6.87958C42.734 8.00521 43.4174 8.40722 44.543 8.40722C45.3873 8.40722 45.9501 8.08561 45.9501 7.563C45.9501 7.08059 45.6687 6.71878 44.744 6.55798L43.3772 6.31677C41.93 6.03536 41.0456 5.03034 41.0456 3.74391C41.0858 1.73387 42.8948 0.889648 44.342 0.889648Z"
    />
  </Icon>
);
